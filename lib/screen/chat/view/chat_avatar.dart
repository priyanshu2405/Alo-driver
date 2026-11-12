import 'package:alo_ride_driver_app/res/constant/app_colors.dart';
import 'package:flutter/material.dart';

/// Customer photo, using the same relative-path convention as the ride screens.
class ChatAvatar extends StatelessWidget {
  final String photo;
  final double size;

  const ChatAvatar({super.key, required this.photo, required this.size});

  @override
  Widget build(BuildContext context) {
    return ClipOval(
      child: Image.network(
        photo,
        width: size,
        height: size,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => Container(
          width: size,
          height: size,
          color: AppColors.lightGray,
          child: Icon(Icons.person, size: size * 0.55, color: AppColors.greyColor),
        ),
      ),
    );
  }
}
