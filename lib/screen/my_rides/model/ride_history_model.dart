// To parse this JSON data, do
//
//     final rideHistoryModel = rideHistoryModelFromJson(jsonString);

import 'dart:convert';

RideHistoryModel rideHistoryModelFromJson(String str) => RideHistoryModel.fromJson(json.decode(str));

String rideHistoryModelToJson(RideHistoryModel data) => json.encode(data.toJson());

class RideHistoryModel {
  bool? success;
  Data? data;

  RideHistoryModel({
    this.success,
    this.data,
  });

  factory RideHistoryModel.fromJson(Map<String, dynamic> json) => RideHistoryModel(
    success: json["success"],
    data: json["data"] == null ? null : Data.fromJson(json["data"]),
  );

  Map<String, dynamic> toJson() => {
    "success": success,
    "data": data?.toJson(),
  };
}

class Data {
  int? currentPage;
  List<RideData>? data;
  String? firstPageUrl;
  int? from;
  int? lastPage;
  String? lastPageUrl;
  List<Link>? links;
  dynamic nextPageUrl;
  String? path;
  int? perPage;
  dynamic prevPageUrl;
  int? to;
  int? total;

  Data({
    this.currentPage,
    this.data,
    this.firstPageUrl,
    this.from,
    this.lastPage,
    this.lastPageUrl,
    this.links,
    this.nextPageUrl,
    this.path,
    this.perPage,
    this.prevPageUrl,
    this.to,
    this.total,
  });

  factory Data.fromJson(Map<String, dynamic> json) => Data(
    currentPage: json["current_page"],
    data: json["data"] == null ? [] : List<RideData>.from(json["data"]!.map((x) => RideData.fromJson(x))),
    firstPageUrl: json["first_page_url"],
    from: json["from"],
    lastPage: json["last_page"],
    lastPageUrl: json["last_page_url"],
    links: json["links"] == null ? [] : List<Link>.from(json["links"]!.map((x) => Link.fromJson(x))),
    nextPageUrl: json["next_page_url"],
    path: json["path"],
    perPage: json["per_page"],
    prevPageUrl: json["prev_page_url"],
    to: json["to"],
    total: json["total"],
  );

  Map<String, dynamic> toJson() => {
    "current_page": currentPage,
    "data": data == null ? [] : List<dynamic>.from(data!.map((x) => x.toJson())),
    "first_page_url": firstPageUrl,
    "from": from,
    "last_page": lastPage,
    "last_page_url": lastPageUrl,
    "links": links == null ? [] : List<dynamic>.from(links!.map((x) => x.toJson())),
    "next_page_url": nextPageUrl,
    "path": path,
    "per_page": perPage,
    "prev_page_url": prevPageUrl,
    "to": to,
    "total": total,
  };
}

class RideData {
  int? id;
  int? userId;
  int? driverId;
  int? vehicleTypeId;
  String? tripType;
  String? pickupLatitude;
  String? pickupLongitude;
  String? pickupAddress;
  String? dropLatitude;
  String? dropLongitude;
  String? dropAddress;
  DateTime? pickupDatetime;
  String? distanceKm;
  String? baseFare;
  String? commissionAmount;
  String? taxAmount;
  String? tipAmount;
  String? totalFare;
  int? rating;
  String? status;
  String? paymentStatus;
  DateTime? acceptedAt;

  /// 🔹 Backend timestamps for the status flow
  DateTime? arrivedAt;
  DateTime? pickupAt;
  DateTime? completedAt;
  DateTime? cancelledAt;
  String? cancellationReason;
  DateTime? createdAt;
  DateTime? updatedAt;
  String? bookingId;
  User? user;
  VehicleType? vehicleType;
  Payment? payment;
  bool? isFlight;
  String? flightNumber;
  int? isPackageStatus;
  String? packageName;

  /// 🔹 Scheduled ride start gating (start allowed only 1 hour before pickup)
  DateTime? startAvailableAt;
  bool? canStart;

  /// 🔹 All drop-off locations, in `sequence` order
  List<Stop>? stops;

  /// Stops ordered by `sequence`. The last one is the final drop-off.
  List<Stop> get orderedStops {
    return List<Stop>.from(stops ?? [])
      ..sort((a, b) => (a.sequence ?? 0).compareTo(b.sequence ?? 0));
  }

  /// Addresses to show after the pickup: every stop ordered by `sequence`,
  /// falling back to the legacy `drop_address` when `stops` is empty.
  List<String> get dropAddresses {
    final addresses = orderedStops
        .map((stop) => stop.address ?? '')
        .where((address) => address.isNotEmpty)
        .toList();

    if (addresses.isEmpty && (dropAddress ?? '').isNotEmpty) {
      return [dropAddress!];
    }

    return addresses;
  }

  double? get dropLatitudeValue => _parseCoordinate(dropLatitude);

  double? get dropLongitudeValue => _parseCoordinate(dropLongitude);

  /// Every point the driver has to reach after the passenger is picked up:
  /// `Stop 1 → Stop 2 → … → Drop Off`. The last entry is always the final
  /// drop-off.
  ///
  /// Backends differ on whether `stops` already contains the drop-off: if none
  /// of the stops sits at `drop_latitude`/`drop_longitude`, the drop-off is
  /// appended so navigation never ends at the last intermediate stop. A ride
  /// with no stops at all still yields a single `Drop Off` entry.
  List<RideDestination> get destinations {
    final dropLat = dropLatitudeValue;
    final dropLng = dropLongitudeValue;
    final hasDropPoint = _isUsableCoordinate(dropLat, dropLng);

    /// Address-only stops are kept — they can still be navigated to and shown,
    /// they just can't be placed on the map or auto-completed by proximity.
    final usableStops = orderedStops
        .where(
          (stop) =>
              _isUsableCoordinate(stop.latitudeValue, stop.longitudeValue) ||
              (stop.address ?? '').trim().isNotEmpty,
        )
        .toList();

    if (usableStops.isEmpty) {
      if (!hasDropPoint && (dropAddress ?? '').trim().isEmpty) return [];
      return [
        RideDestination(
          index: 0,
          latitude: hasDropPoint ? dropLat : null,
          longitude: hasDropPoint ? dropLng : null,
          address: dropAddress ?? '',
          isFinalDrop: true,
          isReached: completedAt != null,
        ),
      ];
    }

    /// Does one of the stops already represent the final drop-off?
    final lastStop = usableStops.last;
    final stopsIncludeDrop = !hasDropPoint ||
        usableStops.any(
          (stop) => _isSamePoint(
            stop.latitudeValue,
            stop.longitudeValue,
            dropLat,
            dropLng,
          ),
        );

    final result = <RideDestination>[];

    for (var index = 0; index < usableStops.length; index++) {
      final stop = usableStops[index];
      final isFinalDrop =
          stopsIncludeDrop && identical(stop, lastStop);
      final hasStopPoint =
          _isUsableCoordinate(stop.latitudeValue, stop.longitudeValue);

      result.add(
        RideDestination(
          index: index,
          stopId: stop.id,
          latitude: hasStopPoint
              ? stop.latitudeValue
              : (isFinalDrop && hasDropPoint ? dropLat : null),
          longitude: hasStopPoint
              ? stop.longitudeValue
              : (isFinalDrop && hasDropPoint ? dropLng : null),
          address: (stop.address ?? '').trim().isNotEmpty
              ? stop.address!
              : (isFinalDrop ? (dropAddress ?? '') : ''),
          isFinalDrop: isFinalDrop,
          isReached: stop.isReached || (isFinalDrop && completedAt != null),
        ),
      );
    }

    /// The stops were intermediate only — append the real drop-off.
    if (!stopsIncludeDrop) {
      result.add(
        RideDestination(
          index: result.length,
          latitude: dropLat,
          longitude: dropLng,
          address: dropAddress ?? '',
          isFinalDrop: true,
          isReached: completedAt != null,
        ),
      );
    }

    return result;
  }

  RideData({
    this.id,
    this.userId,
    this.driverId,
    this.vehicleTypeId,
    this.tripType,
    this.pickupLatitude,
    this.pickupLongitude,
    this.pickupAddress,
    this.dropLatitude,
    this.dropLongitude,
    this.dropAddress,
    this.pickupDatetime,
    this.distanceKm,
    this.baseFare,
    this.commissionAmount,
    this.taxAmount,
    this.tipAmount,
    this.totalFare,
    this.rating,
    this.status,
    this.acceptedAt,
    this.arrivedAt,
    this.pickupAt,
    this.completedAt,
    this.cancelledAt,
    this.cancellationReason,
    this.createdAt,
    this.updatedAt,
    this.bookingId,
    this.user,
    this.vehicleType,
    this.payment,this.paymentStatus,
    this.flightNumber,this.isFlight,this.isPackageStatus,this.packageName,
    this.startAvailableAt,this.canStart,
    this.stops,
  });

  factory RideData.fromJson(Map<String, dynamic> json) => RideData(
    id: json["id"],
    userId: json["user_id"],
    driverId: json["driver_id"],
    vehicleTypeId: json["vehicle_type_id"],
    tripType: json["trip_type"],
    pickupLatitude: json["pickup_latitude"],
    pickupLongitude: json["pickup_longitude"],
    pickupAddress: json["pickup_address"],
    dropLatitude: json["drop_latitude"],
    dropLongitude: json["drop_longitude"],
    dropAddress: json["drop_address"],
    pickupDatetime: json["pickup_datetime"] == null ? null : DateTime.parse(json["pickup_datetime"]),
    distanceKm: json["distance_km"],
    baseFare: json["base_fare"],
    commissionAmount: json["commission_amount"],
    taxAmount: json["tax_amount"],
    tipAmount: json["tip_amount"],
    totalFare: json["total_fare"],
    rating: json["rating"],
    status: json["status"],
    paymentStatus: json["payment_status"],
    acceptedAt: json["accepted_at"] == null ? null : DateTime.parse(json["accepted_at"]),
    arrivedAt: json["arrived_at"] == null ? null : DateTime.tryParse(json["arrived_at"].toString()),
    pickupAt: json["pickup_at"] == null ? null : DateTime.parse(json["pickup_at"]),
    completedAt: json["completed_at"] == null ? null : DateTime.parse(json["completed_at"]),
    cancelledAt: json["cancelled_at"] == null ? null : DateTime.parse(json["cancelled_at"]),
    cancellationReason: json["cancellation_reason"],
    createdAt: json["created_at"] == null ? null : DateTime.parse(json["created_at"]),
    updatedAt: json["updated_at"] == null ? null : DateTime.parse(json["updated_at"]),
    bookingId: json["booking_id"],
    user: json["user"] == null ? null : User.fromJson(json["user"]),
    vehicleType: json["vehicle_type"] == null ? null : VehicleType.fromJson(json["vehicle_type"]),
    payment: json["payment"] == null ? null : Payment.fromJson(json["payment"]),
    isFlight: json['is_flight'],
    flightNumber: json['flight_number'],
    isPackageStatus: json['is_package_status'],
    packageName: json['package_name'],
    startAvailableAt: json["start_available_at"] == null ? null : DateTime.tryParse(json["start_available_at"].toString()),
    canStart: _parseBool(json["can_start"]),
    stops: json["stops"] == null ? [] : List<Stop>.from(json["stops"]!.map((x) => Stop.fromJson(x))),
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "user_id": userId,
    "driver_id": driverId,
    "vehicle_type_id": vehicleTypeId,
    "trip_type": tripType,
    "pickup_latitude": pickupLatitude,
    "pickup_longitude": pickupLongitude,
    "pickup_address": pickupAddress,
    "drop_latitude": dropLatitude,
    "drop_longitude": dropLongitude,
    "drop_address": dropAddress,
    "pickup_datetime": pickupDatetime?.toIso8601String(),
    "distance_km": distanceKm,
    "base_fare": baseFare,
    "commission_amount": commissionAmount,
    "tax_amount": taxAmount,
    "tip_amount": tipAmount,
    "total_fare": totalFare,
    "rating": rating,
    "status": status,
    "payment_status": paymentStatus,
    "accepted_at": acceptedAt?.toIso8601String(),
    "arrived_at": arrivedAt?.toIso8601String(),
    "pickup_at": pickupAt?.toIso8601String(),
    "completed_at": completedAt?.toIso8601String(),
    "cancelled_at": cancelledAt?.toIso8601String(),
    "cancellation_reason": cancellationReason,
    "created_at": createdAt?.toIso8601String(),
    "updated_at": updatedAt?.toIso8601String(),
    "booking_id": bookingId,
    "user": user?.toJson(),
    "vehicle_type": vehicleType?.toJson(),
    "payment": payment?.toJson(),
    'is_flight' :isFlight,
    'flight_number' :flightNumber,
    'is_package_status' :isPackageStatus,
    'package_name' :packageName,
    'start_available_at' :startAvailableAt?.toIso8601String(),
    'can_start' :canStart,
    'stops' :stops == null ? [] : List<dynamic>.from(stops!.map((x) => x.toJson())),
  };
}

class Stop {
  int? id;
  int? rideId;
  int? sequence;
  String? address;
  String? latitude;
  String? longitude;

  /// 🔹 Optional per-stop progress, when the backend sends it.
  String? status;
  DateTime? reachedAt;

  Stop({
    this.id,
    this.rideId,
    this.sequence,
    this.address,
    this.latitude,
    this.longitude,
    this.status,
    this.reachedAt,
  });

  double? get latitudeValue => _parseCoordinate(latitude);

  double? get longitudeValue => _parseCoordinate(longitude);

  bool get isReached =>
      reachedAt != null || status == "reached" || status == "completed";

  factory Stop.fromJson(Map<String, dynamic> json) => Stop(
    id: json["id"],
    rideId: json["ride_id"],
    sequence: json["sequence"] is int ? json["sequence"] : int.tryParse("${json["sequence"]}"),
    address: (json["address"] ?? json["drop_address"] ?? json["stop_address"])?.toString(),
    latitude: json["latitude"]?.toString(),
    longitude: json["longitude"]?.toString(),
    status: json["status"]?.toString(),
    reachedAt: json["reached_at"] == null ? null : DateTime.tryParse(json["reached_at"].toString()),
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "ride_id": rideId,
    "sequence": sequence,
    "address": address,
    "latitude": latitude,
    "longitude": longitude,
    "status": status,
    "reached_at": reachedAt?.toIso8601String(),
  };
}

/// A point on the post-pickup route: an intermediate stop or the final drop-off.
class RideDestination {
  final int index;
  final int? stopId;

  /// `null` when the backend sent no usable coordinates for this point — it is
  /// then navigated to (and displayed) by address.
  final double? latitude;
  final double? longitude;
  final String address;
  final bool isFinalDrop;
  final bool isReached;

  const RideDestination({
    required this.index,
    required this.latitude,
    required this.longitude,
    required this.address,
    required this.isFinalDrop,
    this.stopId,
    this.isReached = false,
  });

  /// "Stop 1", "Stop 2" … "Drop Off"
  String get label => isFinalDrop ? "Drop Off" : "Stop ${index + 1}";

  bool get hasCoordinates => _isUsableCoordinate(latitude, longitude);

  /// Something to navigate to: coordinates, or at least an address.
  bool get isNavigable => hasCoordinates || address.trim().isNotEmpty;

  RideDestination copyWith({bool? isReached}) => RideDestination(
    index: index,
    stopId: stopId,
    latitude: latitude,
    longitude: longitude,
    address: address,
    isFinalDrop: isFinalDrop,
    isReached: isReached ?? this.isReached,
  );
}

/// API coordinates arrive as strings and are sometimes null, empty or "0".
double? _parseCoordinate(String? value) {
  final parsed = double.tryParse((value ?? '').trim());
  if (parsed == null || !parsed.isFinite) return null;
  return parsed;
}

/// Rejects out of range values and the `0,0` null-island the API sends when a
/// location wasn't set — navigating there would send the driver to the ocean.
bool _isUsableCoordinate(double? latitude, double? longitude) {
  if (latitude == null || longitude == null) return false;
  if (!latitude.isFinite || !longitude.isFinite) return false;
  if (latitude.abs() > 90 || longitude.abs() > 180) return false;
  if (latitude == 0 && longitude == 0) return false;
  return true;
}

/// ~55 m tolerance, enough to match a stop against the ride's drop-off point
/// when the two are rounded differently by the backend.
bool _isSamePoint(double? lat1, double? lng1, double? lat2, double? lng2) {
  if (!_isUsableCoordinate(lat1, lng1) || !_isUsableCoordinate(lat2, lng2)) {
    return false;
  }
  const tolerance = 0.0005;
  return (lat1! - lat2!).abs() < tolerance &&
      (lng1! - lng2!).abs() < tolerance;
}

/// API may send `can_start` as bool, 1/0 or "true"/"false".
bool? _parseBool(dynamic value) {
  if (value == null) return null;
  if (value is bool) return value;
  final text = value.toString().toLowerCase();
  return text == "1" || text == "true";
}

class Payment {
  int? id;
  int? rideId;
  String? amount;
  String? currency;
  String? status;
  String? paymentMethod;
  String? transactionId;
  String? stripePaymentIntentId;
  String? stripeChargeId;
  DateTime? paidAt;
  dynamic notes;
  DateTime? createdAt;
  DateTime? updatedAt;
  int? userId;
  int? driverId;

  Payment({
    this.id,
    this.rideId,
    this.amount,
    this.currency,
    this.status,
    this.paymentMethod,
    this.transactionId,
    this.stripePaymentIntentId,
    this.stripeChargeId,
    this.paidAt,
    this.notes,
    this.createdAt,
    this.updatedAt,
    this.userId,
    this.driverId,
  });

  factory Payment.fromJson(Map<String, dynamic> json) => Payment(
    id: json["id"],
    rideId: json["ride_id"],
    amount: json["amount"],
    currency: json["currency"],
    status: json["status"],
    paymentMethod: json["payment_method"],
    transactionId: json["transaction_id"],
    stripePaymentIntentId: json["stripe_payment_intent_id"],
    stripeChargeId: json["stripe_charge_id"],
    paidAt: json["paid_at"] == null ? null : DateTime.parse(json["paid_at"]),
    notes: json["notes"],
    createdAt: json["created_at"] == null ? null : DateTime.parse(json["created_at"]),
    updatedAt: json["updated_at"] == null ? null : DateTime.parse(json["updated_at"]),
    userId: json["user_id"],
    driverId: json["driver_id"],
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "ride_id": rideId,
    "amount": amount,
    "currency": currency,
    "status": status,
    "payment_method": paymentMethod,
    "transaction_id": transactionId,
    "stripe_payment_intent_id": stripePaymentIntentId,
    "stripe_charge_id": stripeChargeId,
    "paid_at": paidAt?.toIso8601String(),
    "notes": notes,
    "created_at": createdAt?.toIso8601String(),
    "updated_at": updatedAt?.toIso8601String(),
    "user_id": userId,
    "driver_id": driverId,
  };
}

class User {
  int? id;
  String? name;
  String? email;
  String? mobile;
  bool? isProfileComplete;
  String? profilePhoto;
  dynamic emailVerifiedAt;
  DateTime? createdAt;
  DateTime? updatedAt;

  User({
    this.id,
    this.name,
    this.email,
    this.mobile,
    this.isProfileComplete,
    this.profilePhoto,
    this.emailVerifiedAt,
    this.createdAt,
    this.updatedAt,
  });

  factory User.fromJson(Map<String, dynamic> json) => User(
    id: json["id"],
    name: json["name"],
    email: json["email"],
    mobile: json["mobile"],
    isProfileComplete: json["is_profile_complete"],
    profilePhoto: json["profile_photo"],
    emailVerifiedAt: json["email_verified_at"],
    createdAt: json["created_at"] == null ? null : DateTime.parse(json["created_at"]),
    updatedAt: json["updated_at"] == null ? null : DateTime.parse(json["updated_at"]),
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "name": name,
    "email": email,
    "mobile": mobile,
    "is_profile_complete": isProfileComplete,
    "profile_photo": profilePhoto,
    "email_verified_at": emailVerifiedAt,
    "created_at": createdAt?.toIso8601String(),
    "updated_at": updatedAt?.toIso8601String(),
  };
}

class VehicleType {
  int? id;
  String? name;
  int? capacity;
  String? pricePerKm;
  String? commissionPercentage;
  bool? isActive;
  String? vehicleImage;
  DateTime? createdAt;
  DateTime? updatedAt;

  VehicleType({
    this.id,
    this.name,
    this.capacity,
    this.pricePerKm,
    this.commissionPercentage,
    this.isActive,
    this.vehicleImage,
    this.createdAt,
    this.updatedAt,
  });

  factory VehicleType.fromJson(Map<String, dynamic> json) => VehicleType(
    id: json["id"],
    name: json["name"],
    capacity: json["capacity"],
    pricePerKm: json["price_per_km"],
    commissionPercentage: json["commission_percentage"],
    isActive: json["is_active"],
    vehicleImage: json["vehicle_image"],
    createdAt: json["created_at"] == null ? null : DateTime.parse(json["created_at"]),
    updatedAt: json["updated_at"] == null ? null : DateTime.parse(json["updated_at"]),
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "name": name,
    "capacity": capacity,
    "price_per_km": pricePerKm,
    "commission_percentage": commissionPercentage,
    "is_active": isActive,
    "vehicle_image": vehicleImage,
    "created_at": createdAt?.toIso8601String(),
    "updated_at": updatedAt?.toIso8601String(),
  };
}

class Link {
  String? url;
  String? label;
  bool? active;

  Link({
    this.url,
    this.label,
    this.active,
  });

  factory Link.fromJson(Map<String, dynamic> json) => Link(
    url: json["url"],
    label: json["label"],
    active: json["active"],
  );

  Map<String, dynamic> toJson() => {
    "url": url,
    "label": label,
    "active": active,
  };
}


class PendingRideHistoryModel {
  bool? success;
  String? message;
  int? count;
  String? radiusKm;
  List<RideData>? data;

  PendingRideHistoryModel({
    this.success,
    this.message,
    this.count,
    this.radiusKm,
    this.data,
  });

  factory PendingRideHistoryModel.fromJson(Map<String, dynamic> json) {
    return PendingRideHistoryModel(
      success: json["success"],
      message: json["message"],
      count: json["count"],
      radiusKm: json["radius_km"],
      data: json["data"] == null
          ? []
          : List<RideData>.from(
          json["data"].map((x) => RideData.fromJson(x))),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "success": success,
      "message": message,
      "count": count,
      "radius_km": radiusKm,
      "data": data?.map((x) => x.toJson()).toList(),
    };
  }
}