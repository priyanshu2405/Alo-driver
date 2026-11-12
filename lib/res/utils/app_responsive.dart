import 'dart:math';
import 'package:flutter/material.dart';

/// ─────────────────────────────────────────────────────────────────
/// Design reference — matches your Figma base (iPhone 14 / 390×844)
/// ─────────────────────────────────────────────────────────────────
const double _kDesignWidth = 390.0;
const double _kDesignHeight = 844.0;

/// ─────────────────────────────────────────────────────────────────
/// WHY scales are clamped
/// ─────────────────────────────────────────────────────────────────
///
/// Without a clamp, a 1024-wide iPad gives scaleW = 2.63×.
/// That turns an 18 sp button label into 47 px — visually broken.
///
/// The solution is **different clamp budgets per dimension type**:
///
///  • Width   (.w)  — unclamped. Horizontal space naturally fills
///                    the screen; padding/gaps should grow on iPad.
///
///  • Height  (.h)  — gently clamped [0.82 → 1.30]. Elements can
///                    be a bit taller on large screens but must not
///                    dominate the viewport.
///
///  • Font    (.sp) — tightly clamped [0.85 → 1.15]. Text size is
///                    a UX decision, not a screen-size ratio.
///                    18 sp stays 15.3–20.7 px across ALL devices.
///
///  • Radius  (.r)  — same budget as font; corners scale with text.
/// ─────────────────────────────────────────────────────────────────

class AppResponsive {
  AppResponsive._();

  static double _screenWidth = _kDesignWidth;
  static double _screenHeight = _kDesignHeight;

  // ── Initialise once inside GetMaterialApp builder ──────────────
  static void init(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    _screenWidth = size.width;
    _screenHeight = size.height;
  }

  // ── Raw dimensions ─────────────────────────────────────────────
  static double get screenWidth => _screenWidth;
  static double get screenHeight => _screenHeight;

  // ── Device type breakpoints ────────────────────────────────────
  /// Phone  : width < 600
  static bool get isMobile => _screenWidth < 600;

  /// Tablet / iPad mini / small iPad  : 600 ≤ width < 900
  static bool get isTablet => _screenWidth >= 600 && _screenWidth < 900;

  /// iPad Pro / large tablet / desktop: width ≥ 900
  static bool get isLargeTablet => _screenWidth >= 900;

  // ── Raw scale factors (private) ────────────────────────────────
  static double get _scaleW => _screenWidth / _kDesignWidth;
  static double get _scaleH => _screenHeight / _kDesignHeight;

  // The "tightest" scale — smallest of width and height ratios.
  // Used as the base for sp/r before clamping.
  static double get _scaleMin => min(_scaleW, _scaleH);

  // ── Public scaling methods ─────────────────────────────────────

  /// Horizontal spacing / container widths.
  /// NOT clamped — padding and gap should grow naturally with screen width.
  static double w(double size) => size * _scaleW;

  /// Vertical spacing / container heights.
  /// Clamped [0.82 → 1.30] so elements stay proportionate on large screens.
  ///
  ///   52.h on iPhone 390  →  52 × 1.00 = 52 px   ✓
  ///   52.h on iPad  768   →  52 × 1.21 = 63 px   ✓
  ///   52.h on iPad Pro    →  52 × 1.30 = 68 px   ✓  (clamped, not 84 px)
  static double h(double size) => size * _scaleH.clamp(0.82, 1.30);

  /// Font size. Tightly clamped [0.85 → 1.15] so text never
  /// balloons on tablets or shrinks to illegibility on small phones.
  ///
  ///   18.sp on iPhone 390  → 18 × 1.00 = 18.0 px  ✓
  ///   18.sp on iPad  768   → 18 × 1.15 = 20.7 px  ✓
  ///   18.sp on iPad Pro    → 18 × 1.15 = 20.7 px  ✓  (was 29 px before)
  ///   18.sp on small 320   → 18 × 0.85 = 15.3 px  ✓
  static double sp(double size) => size * _scaleMin.clamp(0.85, 1.15);

  /// Border radius / icon size. Follows the same budget as [sp].
  static double r(double size) => size * _scaleMin.clamp(0.85, 1.15);

  // ── Convenience helpers ────────────────────────────────────────

  /// Pick a value that fits the current device class.
  ///
  /// ```dart
  /// fontSize: AppResponsive.value(mobile: 14, tablet: 16),
  /// padding:  AppResponsive.value(mobile: 20.w, tablet: 40.w),
  /// ```
  static T value<T>({
    required T mobile,
    required T tablet,
    T? largeTablet,
  }) {
    if (isLargeTablet) return largeTablet ?? tablet;
    if (isTablet) return tablet;
    return mobile;
  }
}

// ─────────────────────────────────────────────────────────────────
// Drop-in num extensions — identical API to flutter_screenutil
// ─────────────────────────────────────────────────────────────────
extension ResponsiveNumExtension on num {
  /// Scaled height
  double get h => AppResponsive.h(toDouble());

  /// Scaled width / horizontal gap
  double get w => AppResponsive.w(toDouble());

  /// Scaled font size  (clamped — see AppResponsive.sp)
  double get sp => AppResponsive.sp(toDouble());

  /// Scaled radius / icon size  (clamped — see AppResponsive.r)
  double get r => AppResponsive.r(toDouble());

  /// Fraction of screen width   — 1.sw = full width, 0.5.sw = half
  double get sw => toDouble() * AppResponsive.screenWidth;

  /// Fraction of screen height  — 1.sh = full height
  double get sh => toDouble() * AppResponsive.screenHeight;
}
