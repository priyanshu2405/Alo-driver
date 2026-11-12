// To parse this JSON data, do
//
//     final getVehicleTypesModel = getVehicleTypesModelFromJson(jsonString);

import 'dart:convert';

GetVehicleTypesModel getVehicleTypesModelFromJson(String str) => GetVehicleTypesModel.fromJson(json.decode(str));

String getVehicleTypesModelToJson(GetVehicleTypesModel data) => json.encode(data.toJson());

class GetVehicleTypesModel {
  bool? success;
  List<Datum>? data;

  GetVehicleTypesModel({
    this.success,
    this.data,
  });

  factory GetVehicleTypesModel.fromJson(Map<String, dynamic> json) => GetVehicleTypesModel(
    success: json["success"],
    data: json["data"] == null ? [] : List<Datum>.from(json["data"]!.map((x) => Datum.fromJson(x))),
  );

  Map<String, dynamic> toJson() => {
    "success": success,
    "data": data == null ? [] : List<dynamic>.from(data!.map((x) => x.toJson())),
  };
}

class Datum {
  int? id;
  String? name;
  int? capacity;
  String? pricePerKm;
  String? commissionPercentage;
  bool? isActive;
  String? vehicleImage;
  DateTime? createdAt;
  DateTime? updatedAt;

  Datum({
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

  factory Datum.fromJson(Map<String, dynamic> json) => Datum(
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
