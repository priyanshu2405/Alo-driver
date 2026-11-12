// To parse this JSON data, do
//
//     final getWeeklyPayoutModel = getWeeklyPayoutModelFromJson(jsonString);

import 'dart:convert';

GetWeeklyPayoutModel getWeeklyPayoutModelFromJson(String str) => GetWeeklyPayoutModel.fromJson(json.decode(str));

String getWeeklyPayoutModelToJson(GetWeeklyPayoutModel data) => json.encode(data.toJson());

class GetWeeklyPayoutModel {
  bool? success;
  Data? data;

  GetWeeklyPayoutModel({
    this.success,
    this.data,
  });

  factory GetWeeklyPayoutModel.fromJson(Map<String, dynamic> json) => GetWeeklyPayoutModel(
    success: json["success"],
    data: json["data"] == null ? null : Data.fromJson(json["data"]),
  );

  Map<String, dynamic> toJson() => {
    "success": success,
    "data": data?.toJson(),
  };
}

class Data {
  double? totalPaid;
  double? totalUnpaid;
  List<Week>? weeks;

  Data({
    this.totalPaid,
    this.totalUnpaid,
    this.weeks,
  });

  factory Data.fromJson(Map<String, dynamic> json) => Data(
    totalPaid: _toDouble(json["total_paid"]),
    totalUnpaid: _toDouble(json["total_unpaid"]),
    weeks: json["weeks"] == null ? [] : List<Week>.from(json["weeks"]!.map((x) => Week.fromJson(x))),
  );

  Map<String, dynamic> toJson() => {
    "total_paid": totalPaid,
    "total_unpaid": totalUnpaid,
    "weeks": weeks == null ? [] : List<dynamic>.from(weeks!.map((x) => x.toJson())),
  };
}

class Week {
  DateTime? weekStart;
  DateTime? weekEnd;
  String? label;
  int? totalRides;
  double? grossFare;
  double? commission;
  double? payout;
  String? status;
  double? amountPaid;
  String? transactionNumber;
  String? paidAt;

  Week({
    this.weekStart,
    this.weekEnd,
    this.label,
    this.totalRides,
    this.grossFare,
    this.commission,
    this.payout,
    this.status,
    this.amountPaid,
    this.transactionNumber,
    this.paidAt,
  });

  factory Week.fromJson(Map<String, dynamic> json) => Week(
    weekStart: json["week_start"] == null ? null : DateTime.tryParse(json["week_start"].toString()),
    weekEnd: json["week_end"] == null ? null : DateTime.tryParse(json["week_end"].toString()),
    label: json["label"],
    totalRides: json["total_rides"] is int ? json["total_rides"] : int.tryParse("${json["total_rides"]}"),
    grossFare: _toDouble(json["gross_fare"]),
    commission: _toDouble(json["commission"]),
    payout: _toDouble(json["payout"]),
    status: json["status"],
    amountPaid: _toDouble(json["amount_paid"]),
    transactionNumber: json["transaction_number"]?.toString(),
    paidAt: json["paid_at"]?.toString(),
  );

  Map<String, dynamic> toJson() => {
    "week_start": weekStart == null ? null : "${weekStart!.year.toString().padLeft(4, '0')}-${weekStart!.month.toString().padLeft(2, '0')}-${weekStart!.day.toString().padLeft(2, '0')}",
    "week_end": weekEnd == null ? null : "${weekEnd!.year.toString().padLeft(4, '0')}-${weekEnd!.month.toString().padLeft(2, '0')}-${weekEnd!.day.toString().padLeft(2, '0')}",
    "label": label,
    "total_rides": totalRides,
    "gross_fare": grossFare,
    "commission": commission,
    "payout": payout,
    "status": status,
    "amount_paid": amountPaid,
    "transaction_number": transactionNumber,
    "paid_at": paidAt,
  };
}

/// Amounts can arrive as num or as a String ("980.00") — parse both safely.
double? _toDouble(dynamic value) {
  if (value == null) return null;
  if (value is num) return value.toDouble();
  return double.tryParse(value.toString());
}
