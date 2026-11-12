/// Single source of truth for the driver ride status flow.
///
/// accepted → going_to_pickup → arrived → pickup_done → completed
///
/// The backend rejects out of sequence updates with
/// `400 - "Invalid status transition"`, so the app always derives the status it
/// posts from the ride's current status instead of hard coding it per screen.
class RideStatus {
  const RideStatus._();

  static const String pending = "pending";
  static const String accepted = "accepted";
  static const String goingToPickup = "going_to_pickup";
  static const String arrived = "arrived";
  static const String pickupDone = "pickup_done";
  static const String completed = "completed";
  static const String cancelled = "cancelled";

  /// Ordered flow. Index position defines what may follow what.
  static const List<String> flow = [
    accepted,
    goingToPickup,
    arrived,
    pickupDone,
    completed,
  ];

  /// The only status that may be posted next for [current], or `null` when the
  /// ride is finished / in an unknown state.
  static String? next(String? current) {
    final index = flow.indexOf(current ?? "");
    if (index < 0 || index >= flow.length - 1) return null;
    return flow[index + 1];
  }

  /// Guards against skipping a step before hitting the API.
  static bool canTransition({required String? from, required String? to}) {
    return to != null && next(from) == to;
  }

  /// Primary action button label for the ride's *current* status.
  /// `null` means the button must be hidden (ride finished / not actionable).
  static String? actionLabel(String? current) {
    switch (current) {
      case accepted:
        return "START RIDE";
      case goingToPickup:
        return "ARRIVED";
      case arrived:
        return "PICK UP";
      case pickupDone:
        return "DROP OFF";
      default:
        return null;
    }
  }

  /// Note sent with the status update, matched to the status being posted.
  static String notesFor(String? status) {
    switch (status) {
      case goingToPickup:
        return "On the way to pickup location";
      case arrived:
        return "Arrived at pickup location";
      case pickupDone:
        return "Passenger picked up successfully";
      case completed:
        return "Ride completed successfully";
      default:
        return "";
    }
  }

  /// Short stage label shown next to the booking id.
  static String stageLabel(String? current) {
    switch (current) {
      case accepted:
        return "Ride accepted";
      case goingToPickup:
        return "On the way to pickup";
      case arrived:
        return "Arrived at pickup";
      case pickupDone:
        return "Heading to drop off";
      case completed:
        return "Ride completed";
      case cancelled:
        return "Ride cancelled";
      default:
        return "";
    }
  }

  /// App bar title per stage.
  static String screenTitle(String? current) {
    switch (current) {
      case accepted:
        return "Ride Details";
      case goingToPickup:
        return "Start Pickup";
      case arrived:
        return "Arrived at Pickup";
      case pickupDone:
        return "Drop Off";
      default:
        return "Ride";
    }
  }

  static bool isFinished(String? status) =>
      status == completed || status == cancelled;

  /// Statuses the driver may cancel from — i.e. the ride is assigned to them
  /// and still running.
  ///
  ///   pending    → no driver on the ride yet
  ///   accepted / going_to_pickup / arrived / pickup_done → cancellable
  ///   completed / cancelled → already finished
  ///
  /// Anything unknown or missing is treated as *not* cancellable, so the
  /// button can never appear on a status the backend hasn't confirmed.
  static const List<String> cancellableStatuses = [
    accepted,
    goingToPickup,
    arrived,
    pickupDone,
  ];

  static bool canCancel(String? status) =>
      status != null && cancellableStatuses.contains(status);

  /// A no-show can only be reported once the driver is **at** the pickup point,
  /// i.e. the backend has confirmed `arrived`. Before that the customer hasn't
  /// been waited for, and after `pickup_done` they're already in the car.
  static bool canReportNoShow(String? status) => status == arrived;
}
