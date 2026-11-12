import 'package:alo_ride_driver_app/res/constant/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:alo_ride_driver_app/res/utils/app_responsive.dart';

class AppButton extends StatelessWidget {
  final String text;
  final VoidCallback? onTap;
  final double? height;
  final double? width;

  final Color backgroundColor;
  final Color textColor;

  /// 🔹 NEW
  final Color? borderColor;
  final double borderWidth;

  final double fontSize;
  final FontWeight fontWeight;
  final double borderRadius;
  final bool isLoading;
  final Widget? icon;
  final EdgeInsetsGeometry? padding;

  const AppButton({
    super.key,
    required this.text,
    required this.onTap,
    this.height,
    this.width,
    this.backgroundColor = AppColors.secondary,
    this.textColor = AppColors.white,

    /// 🔹 Border
    this.borderColor,
    this.borderWidth = 1,

    this.fontSize = 16,
    this.fontWeight = FontWeight.w600,
    this.borderRadius = 10,
    this.isLoading = false,
    this.icon,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    /// 🔹 Disabled = no callback (loading keeps its own look)
    final bool isDisabled = onTap == null && !isLoading;

    return SizedBox(
      width: width ?? 1.sw,
      height: height ?? 52.h,
      child: ElevatedButton(
        onPressed: isLoading ? null : onTap,
        style: ElevatedButton.styleFrom(
          backgroundColor: backgroundColor,
          disabledBackgroundColor: isLoading
              ? backgroundColor
              : backgroundColor.withOpacity(0.4),
          padding: padding,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(borderRadius.r),
            side: borderColor != null
                ? BorderSide(color: borderColor!, width: borderWidth)
                : BorderSide.none,
          ),
        ),
        child: isLoading
            ? SizedBox(
          height: 22.h,
          width: 22.h,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            color: textColor,
          ),
        )
            : Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              icon!,
              SizedBox(width: 8.w),
            ],
            Text(
              text,
              style: TextStyle(
                fontSize: fontSize.sp,
                fontWeight: fontWeight,
                color: isDisabled ? textColor.withOpacity(0.6) : textColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
