import 'package:intl/intl.dart';

/// A day range, both ends inclusive, expressed in the driver's **local** dates.
class EarningsDateRange {
  final DateTime start;
  final DateTime end;

  const EarningsDateRange(this.start, this.end);

  /// "2026-07-20"
  String get startIso => EarningsDateRanges.iso(start);

  String get endIso => EarningsDateRanges.iso(end);

  /// "Jul 20 - Jul 26, 2026" — same shape the API sends in `range_label`.
  String get label =>
      "${DateFormat("MMM d").format(start)} - ${DateFormat("MMM d, yyyy").format(end)}";
}

/// Local (device timezone) date maths for the earnings summary.
///
/// Everything is done on **date-only** `DateTime`s built from the driver's
/// local calendar day, so a UTC/DST shift can never move a ride into the wrong
/// bucket. The API still owns the totals — these ranges are what the app sends
/// up as the driver's "now", and what it falls back to for labels when a
/// section is missing from the response.
class EarningsDateRanges {
  EarningsDateRanges._();

  /// Strips the time-of-day, keeping the local calendar date.
  static DateTime dateOnly(DateTime value) =>
      DateTime(value.year, value.month, value.day);

  /// The driver's current local calendar day.
  static DateTime today([DateTime? now]) => dateOnly(now ?? DateTime.now());

  static DateTime yesterday([DateTime? now]) =>
      today(now).subtract(const Duration(days: 1));

  /// Monday of the week that [now] falls in. `DateTime.weekday` is 1 = Monday
  /// … 7 = Sunday, so Monday is always `weekday - 1` days back.
  static DateTime weekStart([DateTime? now]) {
    final day = today(now);
    return day.subtract(Duration(days: day.weekday - DateTime.monday));
  }

  /// Monday → Sunday of the current week.
  static EarningsDateRange thisWeek([DateTime? now]) {
    final start = weekStart(now);
    return EarningsDateRange(start, start.add(const Duration(days: 6)));
  }

  /// Monday → Sunday of the week before the current one.
  static EarningsDateRange lastWeek([DateTime? now]) {
    final start = weekStart(now).subtract(const Duration(days: 7));
    return EarningsDateRange(start, start.add(const Duration(days: 6)));
  }

  /// "2026-07-25" — the format the backend uses for `date` / `week_start`.
  static String iso(DateTime date) => DateFormat("yyyy-MM-dd").format(date);

  /// Offset from UTC in minutes (e.g. `-240` for EDT), sent to the backend so
  /// it can cut "today" and the Mon–Sun weeks on the driver's clock.
  static int timezoneOffsetMinutes([DateTime? now]) =>
      (now ?? DateTime.now()).timeZoneOffset.inMinutes;
}
