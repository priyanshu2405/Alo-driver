// Models for the ride chat (customer <-> driver).
//
// The backend is polling based — there is no socket for chat. Every model here
// maps 1:1 to the payloads documented for `/api/chat/*`.

/// Delivery state of a bubble. Only [ChatSendStatus.sent] messages exist on the
/// server; the other two are local-only states for optimistic sending.
enum ChatSendStatus { sending, sent, failed }

class ChatMessage {
  final int id;
  final int chatRoomId;
  final String message;
  final String messageType;
  final String senderType;
  final int senderId;

  /// Computed by the server from the caller's token — the ONLY correct way to
  /// decide bubble alignment. Customer id 5 and driver id 5 are different
  /// people, so comparing `senderId` locally gets it wrong.
  final bool isMine;

  final bool isRead;
  final DateTime? readAt;
  final DateTime? createdAt;

  /// Local only. Server messages are always [ChatSendStatus.sent].
  final ChatSendStatus sendStatus;

  const ChatMessage({
    required this.id,
    required this.chatRoomId,
    required this.message,
    required this.messageType,
    required this.senderType,
    required this.senderId,
    required this.isMine,
    required this.isRead,
    this.readAt,
    this.createdAt,
    this.sendStatus = ChatSendStatus.sent,
  });

  /// A temp bubble is anything with a negative id — see
  /// [ChatMessage.optimistic]. Never let one reach `last_message_id`.
  bool get isTemp => id < 0;

  factory ChatMessage.fromJson(Map<String, dynamic> json) => ChatMessage(
    id: _toInt(json["id"]),
    chatRoomId: _toInt(json["chat_room_id"]),
    message: json["message"]?.toString() ?? "",
    messageType: json["message_type"]?.toString() ?? "text",
    senderType: json["sender_type"]?.toString() ?? "",
    senderId: _toInt(json["sender_id"]),
    isMine: json["is_mine"] == true,
    isRead: json["is_read"] == true,
    readAt: _toDate(json["read_at"]),
    createdAt: _toDate(json["created_at"]),
  );

  /// The local bubble shown the instant the driver taps send. The negative id
  /// keeps it out of the dedupe set and out of `last_message_id` until the
  /// server hands back the real row.
  factory ChatMessage.optimistic({
    required int tempId,
    required String text,
    required DateTime now,
  }) => ChatMessage(
    id: tempId,
    chatRoomId: 0,
    message: text,
    messageType: "text",
    senderType: "driver",
    senderId: 0,
    isMine: true,
    isRead: false,
    createdAt: now,
    sendStatus: ChatSendStatus.sending,
  );

  ChatMessage copyWith({bool? isRead, DateTime? readAt, ChatSendStatus? sendStatus}) =>
      ChatMessage(
        id: id,
        chatRoomId: chatRoomId,
        message: message,
        messageType: messageType,
        senderType: senderType,
        senderId: senderId,
        isMine: isMine,
        isRead: isRead ?? this.isRead,
        readAt: readAt ?? this.readAt,
        createdAt: createdAt,
        sendStatus: sendStatus ?? this.sendStatus,
      );
}

/// One page of `GET /api/chat/messages/{ride_id}` — initial load, poll, or
/// scroll-up page. `messages` is always oldest-first.
class ChatThreadPage {
  final int chatRoomId;
  final int rideId;
  final String status;
  final bool hasMoreOlder;
  final List<ChatMessage> messages;

  const ChatThreadPage({
    required this.chatRoomId,
    required this.rideId,
    required this.status,
    required this.hasMoreOlder,
    required this.messages,
  });

  bool get isClosed => status == "closed";

  factory ChatThreadPage.fromJson(Map<String, dynamic> json) => ChatThreadPage(
    chatRoomId: _toInt(json["chat_room_id"]),
    rideId: _toInt(json["ride_id"]),
    status: json["status"]?.toString() ?? "active",
    hasMoreOlder: json["has_more_older"] == true,
    messages: (json["messages"] as List?)
            ?.whereType<Map>()
            .map((e) => ChatMessage.fromJson(Map<String, dynamic>.from(e)))
            .toList() ??
        <ChatMessage>[],
  );
}

/// The other person in the thread. The server already picks the right side —
/// the customer when the driver is calling, the driver when the customer is.
class ChatParty {
  final int id;
  final String name;
  final String mobile;
  final String profilePhoto;

  const ChatParty({required this.id, required this.name, required this.mobile, required this.profilePhoto,});

  factory ChatParty.fromJson(Map<String, dynamic> json) => ChatParty(
    id: _toInt(json["id"]),
    name: json["name"]?.toString() ?? "",
    mobile: json["mobile"]?.toString() ?? "",
    profilePhoto: json["profile_photo"]?.toString() ?? "",
  );
}

/// One row of `GET /api/chat/rooms`.
class ChatRoomSummary {
  final int rideId;
  final int chatRoomId;
  final String status;
  final int unreadCount;
  final DateTime? lastMessageAt;
  final ChatParty? otherParty;
  final ChatMessage? lastMessage;

  const ChatRoomSummary({
    required this.rideId,
    required this.chatRoomId,
    required this.status,
    required this.unreadCount,
    this.lastMessageAt,
    this.otherParty,
    this.lastMessage,
  });

  bool get isClosed => status == "closed";

  factory ChatRoomSummary.fromJson(Map<String, dynamic> json) {
    final last = json["last_message"];
    return ChatRoomSummary(
      rideId: _toInt(json["ride_id"]),
      chatRoomId: _toInt(json["chat_room_id"]),
      status: json["status"]?.toString() ?? "active",
      unreadCount: _toInt(json["unread_count"]),
      lastMessageAt: _toDate(json["last_message_at"]),
      otherParty: json["other_party"] == null
          ? null
          : ChatParty.fromJson(Map<String, dynamic>.from(json["other_party"])),
      // The list endpoint sends a trimmed message object (no `is_mine`), which
      // `ChatMessage.fromJson` tolerates — only `message` is rendered here.
      lastMessage: last is Map
          ? ChatMessage.fromJson(Map<String, dynamic>.from(last))
          : null,
    );
  }
}

/// `GET /api/chat/unread-count` — `rooms` is keyed by RIDE id, not room id.
class ChatUnreadSummary {
  final int total;
  final Map<int, int> byRideId;

  const ChatUnreadSummary({required this.total, required this.byRideId});

  const ChatUnreadSummary.empty() : total = 0, byRideId = const {};

  factory ChatUnreadSummary.fromJson(Map<String, dynamic> json) {
    final rooms = <int, int>{};
    final raw = json["rooms"];
    if (raw is Map) {
      raw.forEach((key, value) {
        final rideId = int.tryParse(key.toString());
        if (rideId != null) rooms[rideId] = _toInt(value);
      });
    }
    return ChatUnreadSummary(total: _toInt(json["total"]), byRideId: rooms);
  }
}

// ── Parsing helpers ──────────────────────────────────────────────────────────

/// FCM data payloads deliver ids as STRINGS; the REST API delivers them as ints.
/// Both reach these models, so every id goes through here.
int _toInt(dynamic value) {
  if (value is int) return value;
  if (value is num) return value.toInt();
  return int.tryParse(value?.toString() ?? "") ?? 0;
}

/// Timestamps arrive as `"2026-08-12 10:30:59"`. They are rendered as-is, the
/// same way the rest of the app treats API timestamps.
DateTime? _toDate(dynamic value) {
  final text = value?.toString();
  if (text == null || text.isEmpty) return null;
  return DateTime.tryParse(text);
}
