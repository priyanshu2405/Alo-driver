import 'package:alo_ride_driver_app/res/utils/ride_status_flow.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('RideStatus.canCancel', () {
    /// The required visibility table, status by status.
    const expected = <String, bool>{
      'pending': false,
      'accepted': true,
      'going_to_pickup': true,
      'arrived': true,
      'pickup_done': true,
      'completed': false,
      'cancelled': false,
    };

    expected.forEach((status, isShown) {
      test('$status → cancel button ${isShown ? "shown" : "hidden"}', () {
        expect(RideStatus.canCancel(status), isShown);
      });
    });

    test('an unknown or missing status hides the button', () {
      expect(RideStatus.canCancel(null), isFalse);
      expect(RideStatus.canCancel(''), isFalse);
      expect(RideStatus.canCancel('Accepted'), isFalse); // case sensitive
      expect(RideStatus.canCancel('no_show'), isFalse);
    });

    test('cancelling never applies to a finished ride', () {
      for (final status in RideStatus.cancellableStatuses) {
        expect(RideStatus.isFinished(status), isFalse);
      }
    });
  });
}
