import 'dart:convert';

import 'package:alo_ride_driver_app/screen/chat/model/chat_models.dart';
import 'package:alo_ride_driver_app/services/api_service.dart';
import 'package:flutter/material.dart';

/// Why a chat call failed, so the UI can react instead of showing a red screen.
///
/// 400 and 403-not-a-participant are NORMAL states, not crashes: a driver can
/// cancel mid-ride, the ride goes back to `pending`, and the chat room keeps
/// belonging to the driver who left.
enum ChatErrorKind {
  /// 400 — no driver assigned yet (or the ride went back to searching).
  noDriverAssigned,

  /// 403 — ride completed / cancelled. History stays readable, sending doesn't.
  chatClosed,

  /// 403 — the room belongs to a different driver. Leave the screen.
  notParticipant,

  /// 404 — ride not found.
  rideNotFound,

  /// 422 — empty / too long message.
  validation,

  /// 429 — more than 30 sends a minute.
  rateLimited,

  /// Network drop, timeout, 500, anything else.
  unknown,
}

class ChatFailure implements Exception {
  final ChatErrorKind kind;
  final String message;
  final int statusCode;

  const ChatFailure({
    required this.kind,
    required this.message,
    required this.statusCode,
  });

  /// True while the ride simply has no chat to show — hide the entry point
  /// rather than surfacing an error.
  bool get isChatUnavailable =>
      kind == ChatErrorKind.noDriverAssigned || kind == ChatErrorKind.notParticipant;

  @override
  String toString() => message;
}

/// Thin wrapper over the polling chat endpoints.
///
/// The chat routes live on the SHARED api root (`/api/chat/...`), not under the
/// driver prefix that [ApiService.baseUrl] points at — hence `useBaseUrl: false`
/// with a fully qualified URL. The Sanctum token decides which side of the
/// conversation the caller is, so the customer app can use an identical client.
class ChatApiService {
  const ChatApiService._();

  /// Chat is not on the live host yet — pointed at the local API for testing.
  /// Switch back to [ApiService.userBaseUrl] once it ships to alodrive.ca:
  ///   static const String _root = ApiService.userBaseUrl;
  // static const String _root = 'https://alodrive.ca/api/';

  static String _url(String path) => '${ApiService.userBaseUrl}$path';

  /// GET /api/chat/messages/{ride_id}
  ///
  /// Three modes, all returning oldest-first:
  ///  * no params            -> latest 30 (initial load)
  ///  * [lastMessageId]      -> only messages newer than that id (poll)
  ///  * [beforeId]           -> the 30 older messages (scroll up)
  ///
  /// Side effect: this call also marks the other party's messages as read.
  static Future<ChatThreadPage> fetchMessages({
    required int rideId,
    int? lastMessageId,
    int? beforeId,
    int perPage = 30,
  }) async {
    return _guard(() async {
      final response = await ApiService.get1(
        endpoint: _url('chat/messages/$rideId'),
        useBaseUrl: false,
        queryParams: {
          if (lastMessageId != null) 'last_message_id': '$lastMessageId',
          if (beforeId != null) 'before_id': '$beforeId',
          'per_page': '$perPage',
        },
      );
      return ChatThreadPage.fromJson(
        Map<String, dynamic>.from(response['data'] ?? const {}),
      );
    });
  }

  /// POST /api/chat/send — max 2000 chars, 30 requests a minute.
  static Future<ChatMessage> sendMessage({
    required int rideId,
    required String message,
    String messageType = 'text',
  }) async {
    return _guard(() async {
      final response = await ApiService.post1(
        endpoint: _url('chat/send'),
        useBaseUrl: false,
        body: {
          'ride_id': rideId,
          'message': message,
          'message_type': messageType,
        },
      );
      return ChatMessage.fromJson(
        Map<String, dynamic>.from(response['data'] ?? const {}),
      );
    });
  }

  /// POST /api/chat/read — updates the other side's read ticks.
  static Future<int> markRead({required int rideId}) async {
    return _guard(() async {
      final response = await ApiService.post1(
        endpoint: _url('chat/read'),
        useBaseUrl: false,
        body: {'ride_id': rideId},
      );
      final data = response['data'];
      if (data is Map && data['marked_read'] != null) {
        return int.tryParse(data['marked_read'].toString()) ?? 0;
      }
      return 0;
    });
  }

  /// GET /api/chat/unread-count — badge source.
  static Future<ChatUnreadSummary> fetchUnreadCount() async {
    return _guard(() async {
      final response = await ApiService.get1(
        endpoint: _url('chat/unread-count'),
        useBaseUrl: false,
      );
      return ChatUnreadSummary.fromJson(
        Map<String, dynamic>.from(response['data'] ?? const {}),
      );
    });
  }

  /// GET /api/chat/rooms — the conversation list.
  static Future<List<ChatRoomSummary>> fetchRooms() async {
    return _guard(() async {
      final response = await ApiService.get1(
        endpoint: _url('chat/rooms'),
        useBaseUrl: false,
      );
      final data = response['data'];
      // 🔥 FULL API RESPONSE
      debugPrint("========== GET /api/chat/rooms ==========");
      debugPrint(const JsonEncoder.withIndent('  ').convert(response));
      debugPrint("==================================================");
      if (data is! List) return <ChatRoomSummary>[];
      return data
          .whereType<Map>()
          .map((e) => ChatRoomSummary.fromJson(Map<String, dynamic>.from(e)))
          .toList();
    });
  }

  /// POST /api/chat/delete — own messages only; someone else's returns 403.
  static Future<void> deleteMessage({required int messageId}) async {
    return _guard(() async {
      await ApiService.post1(
        endpoint: _url('chat/delete'),
        useBaseUrl: false,
        body: {'message_id': messageId},
      );
    });
  }

  /// Turns every transport/HTTP failure into a typed [ChatFailure] so callers
  /// never have to sniff status codes or message strings themselves.
  static Future<T> _guard<T>(Future<T> Function() call) async {
    try {
      return await call();
    } on ApiException catch (e) {
      throw _classify(e);
    } on ChatFailure {
      rethrow;
    } catch (e) {
      throw ChatFailure(
        kind: ChatErrorKind.unknown,
        message: e.toString(),
        statusCode: 0,
      );
    }
  }

  static ChatFailure _classify(ApiException e) {
    final text = e.message.toLowerCase();

    switch (e.statusCode) {
      case 400:
        return ChatFailure(
          kind: ChatErrorKind.noDriverAssigned,
          message: e.message,
          statusCode: 400,
        );
      case 403:
        // Two very different 403s: the room is finished, or this driver was
        // never in it (the previous driver's room after a re-assignment).
        return ChatFailure(
          kind: text.contains('participant')
              ? ChatErrorKind.notParticipant
              : ChatErrorKind.chatClosed,
          message: e.message,
          statusCode: 403,
        );
      case 404:
        return ChatFailure(
          kind: ChatErrorKind.rideNotFound,
          message: e.message,
          statusCode: 404,
        );
      case 422:
        return ChatFailure(
          kind: ChatErrorKind.validation,
          message: e.message,
          statusCode: 422,
        );
      case 429:
        return ChatFailure(
          kind: ChatErrorKind.rateLimited,
          message: 'Sending too fast, please wait a moment.',
          statusCode: 429,
        );
      default:
        return ChatFailure(
          kind: ChatErrorKind.unknown,
          message: e.message,
          statusCode: e.statusCode,
        );
    }
  }
}
