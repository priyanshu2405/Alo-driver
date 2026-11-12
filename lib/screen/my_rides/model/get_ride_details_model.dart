// To parse this JSON data, do
//
//     final getRideDetailsModel = getRideDetailsModelFromJson(jsonString);

import 'dart:convert';

import 'package:alo_ride_driver_app/screen/my_rides/model/ride_history_model.dart'
    show Stop;

GetRideDetailsModel getRideDetailsModelFromJson(String str) => GetRideDetailsModel.fromJson(json.decode(str));

String getRideDetailsModelToJson(GetRideDetailsModel data) => json.encode(data.toJson());

class GetRideDetailsModel {
  bool? success;
  Data? data;

  GetRideDetailsModel({
    this.success,
    this.data,
  });

  factory GetRideDetailsModel.fromJson(Map<String, dynamic> json) => GetRideDetailsModel(
    success: json["success"],
    data: json["data"] == null ? null : Data.fromJson(json["data"]),
  );

  Map<String, dynamic> toJson() => {
    "success": success,
    "data": data?.toJson(),
  };
}

class Data {
  Ride? ride;

  Data({
    this.ride,
  });

  factory Data.fromJson(Map<String, dynamic> json) => Data(
    ride: json["ride"] == null ? null : Ride.fromJson(json["ride"]),
  );

  Map<String, dynamic> toJson() => {
    "ride": ride?.toJson(),
  };
}

class Ride {
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
  dynamic rating;
  String? status;
  DateTime? acceptedAt;
  DateTime? pickupAt;
  DateTime? completedAt;
  dynamic cancelledAt;
  dynamic cancellationReason;
  DateTime? createdAt;
  DateTime? updatedAt;
  String? bookingId;
  User? user;
  VehicleType? vehicleType;
  List<StatusLog>? statusLogs;
  Payment? payment;
  bool? isFlight;
  String? flightNumber;
  int? isPackageStatus;
  String? packageName;

  /// 🔹 Scheduled ride start gating (start allowed only 1 hour before pickup)
  DateTime? startAvailableAt;
  bool? canStart;

  /// 🔹 Trip route points, in `sequence` order
  List<Stop>? stops;

  /// Stops ordered by `sequence`.
  List<Stop> get orderedStops =>
      List<Stop>.from(stops ?? [])
        ..sort((a, b) => (a.sequence ?? 0).compareTo(b.sequence ?? 0));

  /// The stops shown between the pickup and the drop-off.
  ///
  /// Some rides send the final drop-off as the last entry of `stops`; it is
  /// filtered out here so the drop-off isn't listed twice.
  List<Stop> get intermediateStops {
    final ordered = orderedStops;
    if (ordered.isEmpty) return [];

    return ordered.where((stop) => !_isDropOff(stop)).toList();
  }

  bool _isDropOff(Stop stop) {
    final stopLat = double.tryParse(stop.latitude ?? '');
    final stopLng = double.tryParse(stop.longitude ?? '');
    final dropLat = double.tryParse(dropLatitude ?? '');
    final dropLng = double.tryParse(dropLongitude ?? '');

    /// ~55 m tolerance, enough when the two are rounded differently.
    if (stopLat != null && stopLng != null && dropLat != null && dropLng != null) {
      const tolerance = 0.0005;
      if ((stopLat - dropLat).abs() < tolerance &&
          (stopLng - dropLng).abs() < tolerance) {
        return true;
      }
    }

    final stopAddress = (stop.address ?? '').trim().toLowerCase();
    final drop = (dropAddress ?? '').trim().toLowerCase();
    return stopAddress.isNotEmpty && stopAddress == drop;
  }

  Ride({
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
    this.pickupAt,
    this.completedAt,
    this.cancelledAt,
    this.cancellationReason,
    this.createdAt,
    this.updatedAt,
    this.bookingId,
    this.user,
    this.vehicleType,
    this.statusLogs,
    this.payment,
    this.flightNumber,this.isFlight,this.isPackageStatus,this.packageName,
    this.startAvailableAt,this.canStart,
    this.stops,
  });

  factory Ride.fromJson(Map<String, dynamic> json) => Ride(
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
    acceptedAt: json["accepted_at"] == null ? null : DateTime.parse(json["accepted_at"]),
    pickupAt: json["pickup_at"] == null ? null : DateTime.parse(json["pickup_at"]),
    completedAt: json["completed_at"] == null ? null : DateTime.parse(json["completed_at"]),
    cancelledAt: json["cancelled_at"],
    cancellationReason: json["cancellation_reason"],
    createdAt: json["created_at"] == null ? null : DateTime.parse(json["created_at"]),
    updatedAt: json["updated_at"] == null ? null : DateTime.parse(json["updated_at"]),
    bookingId: json["booking_id"],
    user: json["user"] == null ? null : User.fromJson(json["user"]),
    vehicleType: json["vehicle_type"] == null ? null : VehicleType.fromJson(json["vehicle_type"]),
    statusLogs: json["status_logs"] == null ? [] : List<StatusLog>.from(json["status_logs"]!.map((x) => StatusLog.fromJson(x))),
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
    "accepted_at": acceptedAt?.toIso8601String(),
    "pickup_at": pickupAt?.toIso8601String(),
    "completed_at": completedAt?.toIso8601String(),
    "cancelled_at": cancelledAt,
    "cancellation_reason": cancellationReason,
    "created_at": createdAt?.toIso8601String(),
    "updated_at": updatedAt?.toIso8601String(),
    "booking_id": bookingId,
    "user": user?.toJson(),
    "vehicle_type": vehicleType?.toJson(),
    "status_logs": statusLogs == null ? [] : List<dynamic>.from(statusLogs!.map((x) => x.toJson())),
    "payment": payment?.toJson(),
    'is_flight' :isFlight,
    'flight_number' :flightNumber,
    "is_package_status" : isPackageStatus,
    "package_name" : packageName,
    "start_available_at" : startAvailableAt?.toIso8601String(),
    "can_start" : canStart,
    "stops" : stops == null ? [] : List<dynamic>.from(stops!.map((x) => x.toJson())),
  };
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
  dynamic paymentMethod;
  dynamic transactionId;
  dynamic stripePaymentIntentId;
  dynamic stripeChargeId;
  dynamic paidAt;
  dynamic notes;
  DateTime? createdAt;
  DateTime? updatedAt;
  dynamic userId;
  dynamic driverId;

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
    paidAt: json["paid_at"],
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
    "paid_at": paidAt,
    "notes": notes,
    "created_at": createdAt?.toIso8601String(),
    "updated_at": updatedAt?.toIso8601String(),
    "user_id": userId,
    "driver_id": driverId,
  };
}

class StatusLog {
  int? id;
  int? rideId;
  String? status;
  String? notes;
  DateTime? createdAt;
  DateTime? updatedAt;

  StatusLog({
    this.id,
    this.rideId,
    this.status,
    this.notes,
    this.createdAt,
    this.updatedAt,
  });

  factory StatusLog.fromJson(Map<String, dynamic> json) => StatusLog(
    id: json["id"],
    rideId: json["ride_id"],
    status: json["status"],
    notes: json["notes"],
    createdAt: json["created_at"] == null ? null : DateTime.parse(json["created_at"]),
    updatedAt: json["updated_at"] == null ? null : DateTime.parse(json["updated_at"]),
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "ride_id": rideId,
    "status": status,
    "notes": notes,
    "created_at": createdAt?.toIso8601String(),
    "updated_at": updatedAt?.toIso8601String(),
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
