// GET /api/driver/earnings
//
//     final driverEarningsModel = driverEarningsModelFromJson(jsonString);

import 'dart:convert';

import 'package:alo_ride_driver_app/screen/earnings/model/earnings_date_range.dart';
import 'package:intl/intl.dart';

DriverEarningsModel driverEarningsModelFromJson(String str) =>
    DriverEarningsModel.fromJson(json.decode(str));

String driverEarningsModelToJson(DriverEarningsModel data) =>
    json.encode(data.toJson());

class DriverEarningsModel {
  bool? success;
  EarningsData? data;

  DriverEarningsModel({this.success, this.data});

  factory DriverEarningsModel.fromJson(Map<String, dynamic> json) =>
      DriverEarningsModel(
        success: json["success"],
        data: json["data"] == null ? null : EarningsData.fromJson(json["data"]),
      );

  Map<String, dynamic> toJson() => {"success": success, "data": data?.toJson()};
}

class EarningsData {
  String? currency;
  EarningsPeriod? today;
  EarningsPeriod? yesterday;
  EarningsPeriod? thisWeek;
  EarningsPeriod? lastWeek;

  EarningsData({
    this.currency,
    this.today,
    this.yesterday,
    this.thisWeek,
    this.lastWeek,
  });

  factory EarningsData.fromJson(Map<String, dynamic> json) => EarningsData(
    currency: json["currency"]?.toString(),
    today: EarningsPeriod.fromJsonOrNull(json["today"]),
    yesterday: EarningsPeriod.fromJsonOrNull(json["yesterday"]),
    thisWeek: EarningsPeriod.fromJsonOrNull(json["this_week"]),
    lastWeek: EarningsPeriod.fromJsonOrNull(json["last_week"]),
  );

  Map<String, dynamic> toJson() => {
    "currency": currency,
    "today": today?.toJson(),
    "yesterday": yesterday?.toJson(),
    "this_week": thisWeek?.toJson(),
    "last_week": lastWeek?.toJson(),
  };
}

/// One bucket of the summary — a single day (`date`) or a Mon–Sun week
/// (`week_start` / `week_end`). The same shape covers both.
class EarningsPeriod {
  String? label;
  DateTime? date;
  DateTime? weekStart;
  DateTime? weekEnd;
  String? rangeLabel;
  int? rides;
  double? grossFare;
  double? commission;
  double? tips;
  double? earnings;

  EarningsPeriod({
    this.label,
    this.date,
    this.weekStart,
    this.weekEnd,
    this.rangeLabel,
    this.rides,
    this.grossFare,
    this.commission,
    this.tips,
    this.earnings,
  });

  static EarningsPeriod? fromJsonOrNull(dynamic json) =>
      json is Map<String, dynamic> ? EarningsPeriod.fromJson(json) : null;

  factory EarningsPeriod.fromJson(Map<String, dynamic> json) => EarningsPeriod(
    label: json["label"]?.toString(),
    date: _toDate(json["date"]),
    weekStart: _toDate(json["week_start"]),
    weekEnd: _toDate(json["week_end"]),
    rangeLabel: json["range_label"]?.toString(),
    rides: _toInt(json["rides"]),
    grossFare: _toDouble(json["gross_fare"]),
    commission: _toDouble(json["commission"]),
    tips: _toDouble(json["tips"]),
    earnings: _toDouble(json["earnings"]),
  );

  Map<String, dynamic> toJson() => {
    "label": label,
    "date": date == null ? null : EarningsDateRanges.iso(date!),
    "week_start": weekStart == null ? null : EarningsDateRanges.iso(weekStart!),
    "week_end": weekEnd == null ? null : EarningsDateRanges.iso(weekEnd!),
    "range_label": rangeLabel,
    "rides": rides,
    "gross_fare": grossFare,
    "commission": commission,
    "tips": tips,
    "earnings": earnings,
  };

  /// An all-zero bucket, used when the API omits a section so the card still
  /// renders with the right title and (locally computed) date range.
  factory EarningsPeriod.empty({
    required String label,
    DateTime? date,
    EarningsDateRange? range,
  }) => EarningsPeriod(
    label: label,
    date: date,
    weekStart: range?.start,
    weekEnd: range?.end,
    rangeLabel: range?.label,
    rides: 0,
    grossFare: 0,
    commission: 0,
    tips: 0,
    earnings: 0,
  );

  double get earningsValue => earnings ?? 0;

  int get ridesCount => rides ?? 0;

  /// What the card shows under the title: the backend's `range_label` when it
  /// sends one, otherwise a range/date built from the dates it did send.
  String? get subtitle {
    final apiLabel = rangeLabel?.trim();
    if (apiLabel != null && apiLabel.isNotEmpty) return apiLabel;

    if (weekStart != null && weekEnd != null) {
      return EarningsDateRange(weekStart!, weekEnd!).label;
    }
    if (date != null) return DateFormat("MMM d, yyyy").format(date!);

    return null;
  }
}

/// Dates arrive as "2026-07-25"; parse defensively and keep them date-only so
/// they can never be shifted by a timezone conversion.
DateTime? _toDate(dynamic value) {
  if (value == null) return null;
  final parsed = DateTime.tryParse(value.toString());
  return parsed == null ? null : EarningsDateRanges.dateOnly(parsed);
}

/// Amounts can arrive as num or as a String ("81.97") — parse both safely.
double? _toDouble(dynamic value) {
  if (value == null) return null;
  if (value is num) return value.toDouble();
  return double.tryParse(value.toString());
}

int? _toInt(dynamic value) {
  if (value == null) return null;
  if (value is int) return value;
  if (value is num) return value.toInt();
  return int.tryParse(value.toString());
}
