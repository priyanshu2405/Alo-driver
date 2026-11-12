// To parse this JSON data, do
//
//     final getProfileModel = getProfileModelFromJson(jsonString);

import 'dart:convert';

GetProfileModel getProfileModelFromJson(String str) => GetProfileModel.fromJson(json.decode(str));

String getProfileModelToJson(GetProfileModel data) => json.encode(data.toJson());

class GetProfileModel {
  bool? success;
  Data? data;

  GetProfileModel({
    this.success,
    this.data,
  });

  factory GetProfileModel.fromJson(Map<String, dynamic> json) => GetProfileModel(
    success: json["success"],
    data: json["data"] == null ? null : Data.fromJson(json["data"]),
  );

  Map<String, dynamic> toJson() => {
    "success": success,
    "data": data?.toJson(),
  };
}

class Data {
  Driver? driver;

  Data({
    this.driver,
  });

  factory Data.fromJson(Map<String, dynamic> json) => Data(
    driver: json["driver"] == null ? null : Driver.fromJson(json["driver"]),
  );

  Map<String, dynamic> toJson() => {
    "driver": driver?.toJson(),
  };
}

class Driver {
  int? id;
  String? name;
  String? email;
  String? mobile;
  String? vehicleNumber;
  int? vehicleTypeId;
  String? profilePhoto;
  String? status;
  bool? isOnline;
  dynamic latitude;
  dynamic longitude;
  dynamic lastLocationUpdate;
  DateTime? createdAt;
  DateTime? updatedAt;
  VehicleType? vehicleType;
  List<Document>? documents;

  Driver({
    this.id,
    this.name,
    this.email,
    this.mobile,
    this.vehicleNumber,
    this.vehicleTypeId,
    this.profilePhoto,
    this.status,
    this.isOnline,
    this.latitude,
    this.longitude,
    this.lastLocationUpdate,
    this.createdAt,
    this.updatedAt,
    this.vehicleType,
    this.documents,
  });

  factory Driver.fromJson(Map<String, dynamic> json) => Driver(
    id: json["id"],
    name: json["name"],
    email: json["email"],
    mobile: json["mobile"],
    vehicleNumber: json["vehicle_number"],
    vehicleTypeId: json["vehicle_type_id"],
    profilePhoto: json["profile_photo"],
    status: json["status"],
    isOnline: json["is_online"],
    latitude: json["latitude"],
    longitude: json["longitude"],
    lastLocationUpdate: json["last_location_update"],
    createdAt: json["created_at"] == null ? null : DateTime.parse(json["created_at"]),
    updatedAt: json["updated_at"] == null ? null : DateTime.parse(json["updated_at"]),
    vehicleType: json["vehicle_type"] == null ? null : VehicleType.fromJson(json["vehicle_type"]),
    documents: json["documents"] == null ? [] : List<Document>.from(json["documents"]!.map((x) => Document.fromJson(x))),
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "name": name,
    "email": email,
    "mobile": mobile,
    "vehicle_number": vehicleNumber,
    "vehicle_type_id": vehicleTypeId,
    "profile_photo": profilePhoto,
    "status": status,
    "is_online": isOnline,
    "latitude": latitude,
    "longitude": longitude,
    "last_location_update": lastLocationUpdate,
    "created_at": createdAt?.toIso8601String(),
    "updated_at": updatedAt?.toIso8601String(),
    "vehicle_type": vehicleType?.toJson(),
    "documents": documents == null ? [] : List<dynamic>.from(documents!.map((x) => x.toJson())),
  };
}

class Document {
  int? id;
  int? driverId;
  String? documentType;
  String? documentPath;
  String? status;
  dynamic rejectionReason;
  DateTime? createdAt;
  DateTime? updatedAt;

  Document({
    this.id,
    this.driverId,
    this.documentType,
    this.documentPath,
    this.status,
    this.rejectionReason,
    this.createdAt,
    this.updatedAt,
  });

  factory Document.fromJson(Map<String, dynamic> json) => Document(
    id: json["id"],
    driverId: json["driver_id"],
    documentType: json["document_type"],
    documentPath: json["document_path"],
    status: json["status"],
    rejectionReason: json["rejection_reason"],
    createdAt: json["created_at"] == null ? null : DateTime.parse(json["created_at"]),
    updatedAt: json["updated_at"] == null ? null : DateTime.parse(json["updated_at"]),
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "driver_id": driverId,
    "document_type": documentType,
    "document_path": documentPath,
    "status": status,
    "rejection_reason": rejectionReason,
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
