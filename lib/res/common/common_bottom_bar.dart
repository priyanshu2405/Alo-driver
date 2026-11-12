import 'package:alo_ride_driver_app/res/constant/app_colors.dart';
import 'package:flutter/material.dart';

class CommonBottomBar extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;

  const CommonBottomBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      child: BottomNavigationBar(
        currentIndex: currentIndex,
        onTap: onTap,
        backgroundColor: AppColors.secondary,
        // elevation: 0,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Colors.white,
        unselectedItemColor: Colors.white.withOpacity(0.7),
        selectedLabelStyle: TextStyle(
          fontWeight: FontWeight.w500,
          color: AppColors.white,
        ),
        unselectedLabelStyle: TextStyle(
          fontWeight: FontWeight.w500,
          color: Colors.white.withOpacity(0.7),
        ),
        items: [
          _buildBottomNavItem(icon: Icons.home_filled, label: 'Home', index: 0),
          _buildBottomNavItem(icon: Icons.car_rental, label: 'New Request', index: 1),
          _buildBottomNavItem(icon: Icons.directions_car, label: 'Ongoing', index: 2),
          _buildBottomNavItem(icon: Icons.directions_car, label: 'My Rides', index: 3),
          _buildBottomNavItem(icon: Icons.person_outline,label: 'Profile', index: 4),
        ],
      ),
    );
  }

  BottomNavigationBarItem _buildBottomNavItem({
    IconData? icon,
    required String label,
    required int index,
  }) {
    return BottomNavigationBarItem(
      icon: Container(
        // padding: EdgeInsets.only(top: index == 2 ? 20 : 0),
        child: icon != null ? Icon(icon) : SizedBox.shrink(),
      ),
      label: label,
    );
  }
}