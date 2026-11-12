/// Response of `POST rides/{id}/no-show`.
///
/// ```json
/// {
///   "ride_id": 468,
///   "booking_id": "000468",
///   "status": "cancelled",
///   "no_show_at": "2026-08-11 01:39:11",
///   "fee": {
///     "status": "paid",
///     "amount": 6,
///     "currency": "CAD",
///     "message": "No-show fee charged successfully.",
///     "card": { "id": 7, "brand": "visa", "last4": "4242" },
///     "payment_intent_id": "pi_3U37T148CBcSJMq2249Y2Oy6"
///   }
/// }
/// ```
///
/// Every displayed value comes from this payload — the amount, the currency and
/// the fee status are never assumed by the app, because the backend owns the
/// no-show policy (and may decide not to charge at all, in which case [fee] is
/// missing or carries a non-`paid` status).
class NoShowResult {
  final int? rideId;
  final String? bookingId;

  /// The ride's new status, e.g. `cancelled`.
  final String? status;

  /// When the no-show was recorded. Sent as `"yyyy-MM-dd HH:mm:ss"`.
  final DateTime? noShowAt;

  final NoShowFee? fee;

  const NoShowResult({
    this.rideId,
    this.bookingId,
    this.status,
    this.noShowAt,
    this.fee,
  });

  factory NoShowResult.fromJson(Map<String, dynamic> json) {
    return NoShowResult(
      rideId: _asInt(json["ride_id"]),
      bookingId: json["booking_id"]?.toString(),
      status: json["status"]?.toString(),
      noShowAt: parseTimestamp(json["no_show_at"]),
      fee: json["fee"] is Map
          ? NoShowFee.fromJson(Map<String, dynamic>.from(json["fee"]))
          : null,
    );
  }

  /// `"2026-08-11 01:39:11"` isn't ISO-8601, so the space is swapped for a `T`
  /// before parsing; anything already ISO parses as is.
  static DateTime? parseTimestamp(dynamic value) {
    final raw = value?.toString().trim() ?? '';
    if (raw.isEmpty) return null;
    return DateTime.tryParse(raw) ?? DateTime.tryParse(raw.replaceFirst(' ', 'T'));
  }

  static int? _asInt(dynamic value) {
    if (value is int) return value;
    return int.tryParse(value?.toString() ?? '');
  }
}

/// The fee the customer was charged for the no-show.
class NoShowFee {
  /// e.g. `paid`, `pending`, `failed` — decided by the backend.
  final String? status;

  /// Kept as a [num] so `6` and `6.5` both display correctly.
  final num? amount;

  /// e.g. `CAD`. Never hard coded in the UI.
  final String? currency;

  /// Backend message, e.g. "No-show fee charged successfully."
  final String? message;

  final NoShowCard? card;
  final String? paymentIntentId;

  const NoShowFee({
    this.status,
    this.amount,
    this.currency,
    this.message,
    this.card,
    this.paymentIntentId,
  });

  factory NoShowFee.fromJson(Map<String, dynamic> json) {
    return NoShowFee(
      status: json["status"]?.toString(),
      amount: json["amount"] is num
          ? json["amount"] as num
          : num.tryParse(json["amount"]?.toString() ?? ''),
      currency: json["currency"]?.toString(),
      message: json["message"]?.toString(),
      card: json["card"] is Map
          ? NoShowCard.fromJson(Map<String, dynamic>.from(json["card"]))
          : null,
      paymentIntentId: json["payment_intent_id"]?.toString(),
    );
  }

  bool get isPaid => status?.toLowerCase() == 'paid';

  /// `"CAD 6.00"` — currency first, both straight from the API. Returns `null`
  /// when the backend sent no amount, so the row can be hidden instead of
  /// showing a made up number.
  String? get formattedAmount {
    final value = amount;
    if (value == null) return null;

    final text = value % 1 == 0
        ? value.toStringAsFixed(2)
        : value.toString();

    final code = currency?.trim() ?? '';
    return code.isEmpty ? text : "$code $text";
  }
}

/// The card the fee was charged to.
class NoShowCard {
  final int? id;
  final String? brand;
  final String? last4;

  const NoShowCard({this.id, this.brand, this.last4});

  factory NoShowCard.fromJson(Map<String, dynamic> json) {
    return NoShowCard(
      id: json["id"] is int ? json["id"] as int : int.tryParse(json["id"]?.toString() ?? ''),
      brand: json["brand"]?.toString(),
      last4: json["last4"]?.toString(),
    );
  }

  /// `"Visa •••• 4242"`, skipping whichever half the API didn't send.
  String? get label {
    final brandName = (brand ?? '').trim();
    final tail = (last4 ?? '').trim();

    final prettyBrand = brandName.isEmpty
        ? ''
        : brandName[0].toUpperCase() + brandName.substring(1);

    if (prettyBrand.isEmpty && tail.isEmpty) return null;
    if (tail.isEmpty) return prettyBrand;
    if (prettyBrand.isEmpty) return "•••• $tail";
    return "$prettyBrand •••• $tail";
  }
}
