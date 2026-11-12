class RideRequestModel {
  final int rideId;
  final String tripType;
  final double distanceKm;
  final double totalFare;
  final String pickupAddress;
  final String dropAddress;
  final String pickupDatetime;
  final String type;
  final int userId;
  final String userImage;
  final String userName;

  RideRequestModel({
    required this.rideId,
    required this.tripType,
    required this.distanceKm,
    required this.totalFare,
    required this.pickupAddress,
    required this.dropAddress,
    required this.pickupDatetime,
    required this.type,
    required this.userId,
    required this.userImage,
    required this.userName,
  });

  factory RideRequestModel.fromMap(Map<String, dynamic> map) {
    return RideRequestModel(
      rideId: int.parse(map['ride_id'].toString()),
      userId: int.parse(map['user_id'].toString()),
      tripType: map['trip_type']?.toString() ?? '',
      distanceKm: double.tryParse(map['distance_km'].toString()) ?? 0.0,
      totalFare: double.tryParse(map['total_fare'].toString()) ?? 0.0,
      pickupAddress: map['pickup_address']?.toString() ?? '',
      dropAddress: map['drop_address']?.toString() ?? '',
      pickupDatetime: map['pickup_datetime']?.toString() ?? '',
      type: map['type']?.toString() ?? '',
      userImage: map['user_image']?.toString() ?? '',
      userName: map['user_name']?.toString() ?? "",
    );
  }
}
