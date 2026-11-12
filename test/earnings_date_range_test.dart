import 'package:alo_ride_driver_app/screen/earnings/model/driver_earnings_model.dart';
import 'package:alo_ride_driver_app/screen/earnings/model/earnings_date_range.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('EarningsDateRanges', () {
    // Saturday 25 Jul 2026, late evening local time.
    final saturday = DateTime(2026, 7, 25, 23, 30);

    test('today / yesterday drop the time of day', () {
      expect(EarningsDateRanges.today(saturday), DateTime(2026, 7, 25));
      expect(EarningsDateRanges.yesterday(saturday), DateTime(2026, 7, 24));
    });

    test('this week runs Monday to Sunday', () {
      final week = EarningsDateRanges.thisWeek(saturday);
      expect(week.start, DateTime(2026, 7, 20));
      expect(week.end, DateTime(2026, 7, 26));
      expect(week.start.weekday, DateTime.monday);
      expect(week.end.weekday, DateTime.sunday);
      expect(week.label, "Jul 20 - Jul 26, 2026");
    });

    test('last week is the preceding Monday to Sunday', () {
      final week = EarningsDateRanges.lastWeek(saturday);
      expect(week.start, DateTime(2026, 7, 13));
      expect(week.end, DateTime(2026, 7, 19));
      expect(week.label, "Jul 13 - Jul 19, 2026");
    });

    test('Sunday still belongs to the week that started on Monday', () {
      final sunday = DateTime(2026, 7, 26, 0, 5);
      final week = EarningsDateRanges.thisWeek(sunday);
      expect(week.start, DateTime(2026, 7, 20));
      expect(week.end, DateTime(2026, 7, 26));
    });

    test('Monday starts a new week', () {
      final monday = DateTime(2026, 7, 27, 0, 1);
      expect(EarningsDateRanges.thisWeek(monday).start, DateTime(2026, 7, 27));
      expect(EarningsDateRanges.lastWeek(monday).start, DateTime(2026, 7, 20));
      expect(EarningsDateRanges.lastWeek(monday).end, DateTime(2026, 7, 26));
    });

    test('week ranges hold across a month/year boundary', () {
      final newYearsDay = DateTime(2027, 1, 1, 9); // Friday
      final week = EarningsDateRanges.thisWeek(newYearsDay);
      expect(week.start, DateTime(2026, 12, 28));
      expect(week.end, DateTime(2027, 1, 3));
    });
  });

  group('DriverEarningsModel', () {
    final json = {
      "success": true,
      "data": {
        "currency": "CAD",
        "today": {
          "label": "Today",
          "date": "2026-07-25",
          "rides": 0,
          "gross_fare": 0,
          "commission": 0,
          "tips": 0,
          "earnings": 0,
        },
        "yesterday": {
          "label": "Yesterday",
          "date": "2026-07-24",
          "rides": 3,
          "gross_fare": 81.97,
          "commission": 0,
          "tips": 0,
          "earnings": 81.97,
        },
        "this_week": {
          "label": "This Week",
          "week_start": "2026-07-20",
          "week_end": "2026-07-26",
          "range_label": "Jul 20 - Jul 26, 2026",
          "rides": 5,
          "gross_fare": 111.95,
          "commission": 0,
          "tips": 0,
          "earnings": 111.95,
        },
        "last_week": {
          "label": "Last Week",
          "week_start": "2026-07-13",
          "week_end": "2026-07-19",
          "range_label": "Jul 13 - Jul 19, 2026",
          "rides": 5,
          "gross_fare": "63.95",
          "commission": 0,
          "tips": 1,
          "earnings": "63.95",
        },
      },
    };

    test('parses every period from the API payload', () {
      final model = DriverEarningsModel.fromJson(json);
      final data = model.data!;

      expect(data.currency, "CAD");
      expect(data.today!.earningsValue, 0);
      expect(data.yesterday!.earningsValue, 81.97);
      expect(data.yesterday!.ridesCount, 3);
      expect(data.thisWeek!.earningsValue, 111.95);
      expect(data.thisWeek!.weekStart, DateTime(2026, 7, 20));
      expect(data.thisWeek!.weekEnd, DateTime(2026, 7, 26));

      /// Amounts sent as strings parse too.
      expect(data.lastWeek!.earningsValue, 63.95);
      expect(data.lastWeek!.tips, 1);
    });

    test('subtitle prefers range_label, then dates', () {
      final data = DriverEarningsModel.fromJson(json).data!;
      expect(data.thisWeek!.subtitle, "Jul 20 - Jul 26, 2026");
      expect(data.yesterday!.subtitle, "Jul 24, 2026");

      final noLabel = EarningsPeriod.fromJson({
        "week_start": "2026-07-13",
        "week_end": "2026-07-19",
      });
      expect(noLabel.subtitle, "Jul 13 - Jul 19, 2026");
    });

    test('a missing section falls back to a zeroed local period', () {
      final model = DriverEarningsModel.fromJson({
        "success": true,
        "data": {"currency": "CAD"},
      });
      expect(model.data!.thisWeek, isNull);

      final fallback = EarningsPeriod.empty(
        label: "This Week",
        range: EarningsDateRanges.thisWeek(DateTime(2026, 7, 25)),
      );
      expect(fallback.earningsValue, 0);
      expect(fallback.ridesCount, 0);
      expect(fallback.subtitle, "Jul 20 - Jul 26, 2026");
    });
  });
}
