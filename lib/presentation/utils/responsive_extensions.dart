import 'package:flutter/material.dart';

/// Extension on [BuildContext] providing dynamic, responsive dimension calculations,
/// scalable typography and icons, and viewport breakpoint helpers.
///
/// Designed in strict compliance with the responsive UI specification
/// to eliminate rigid fixed pixel values across the presentation layer.
extension ResponsiveContext on BuildContext {
  /// Base viewport reference dimension (standard modern device width: 390pt).
  static const double _baseWidth = 390.0;
  static const double _baseLandscapeHeight = 640.0;

  /// Cached screen size using Flutter's optimized [MediaQuery.sizeOf]
  /// to avoid unnecessary widget rebuilds when unrelated MediaQuery fields change.
  Size get screenSize => MediaQuery.sizeOf(this);

  /// Total width of the current screen/viewport.
  double get screenWidth => screenSize.width;

  /// Total height of the current screen/viewport.
  double get screenHeight => screenSize.height;

  /// Current screen orientation.
  Orientation get orientation => MediaQuery.orientationOf(this);

  /// True when the device is in landscape orientation.
  bool get isLandscape => orientation == Orientation.landscape;

  /// True when the device is in portrait orientation.
  bool get isPortrait => orientation == Orientation.portrait;

  /// True when the device is identified as a tablet (shortest side >= 600).
  bool get isTablet => screenSize.shortestSide >= 600;

  /// True when the device is a compact mobile phone (width < 380 in portrait).
  bool get isSmallPhone => screenWidth < 380 && isPortrait;

  /// Calculates a dynamic dimension proportional to the screen width.
  /// Example: `context.w(0.8)` -> 80% of screen width.
  double w(double factor) => screenWidth * factor;

  /// Calculates a dynamic dimension proportional to the screen height.
  /// Example: `context.h(0.3)` -> 30% of screen height.
  double h(double factor) => screenHeight * factor;

  /// Calculates proportional padding based on screen width.
  /// Example: `context.padding(0.04)` -> 4% of screen width.
  double padding(double factor) => screenWidth * factor;

  /// Scaled font size based on the design baseline with clamping
  /// to prevent text overflow on compact screens or excessive magnification on tablets.
  double sp(double baseSize, {double? min, double? max}) {
    final scale = isLandscape
        ? (screenHeight / _baseLandscapeHeight).clamp(0.80, 1.35)
        : (screenWidth / _baseWidth).clamp(0.85, 1.40);

    final scaled = baseSize * scale;
    final minBound = min ?? (baseSize * 0.80);
    final maxBound = max ?? (baseSize * 1.50);

    return scaled.clamp(minBound, maxBound);
  }

  /// Scaled icon size based on the design baseline with adaptive bounds.
  double iconSize(double baseSize, {double? min, double? max}) {
    final scale = isLandscape
        ? (screenHeight / _baseLandscapeHeight).clamp(0.80, 1.30)
        : (screenWidth / _baseWidth).clamp(0.85, 1.35);

    final scaled = baseSize * scale;
    final minBound = min ?? (baseSize * 0.80);
    final maxBound = max ?? (baseSize * 1.45);

    return scaled.clamp(minBound, maxBound);
  }

  /// Proportional EdgeInsets symmetric helper.
  EdgeInsets paddingSymmetric({
    double horizontal = 0.0,
    double vertical = 0.0,
  }) {
    return EdgeInsets.symmetric(
      horizontal: w(horizontal),
      vertical: h(vertical),
    );
  }

  /// Proportional EdgeInsets all helper.
  EdgeInsets paddingAll(double factor) => EdgeInsets.all(padding(factor));

  /// Dynamic vertical space SizedBox.
  Widget verticalSpace(double factor) => SizedBox(height: h(factor));

  /// Dynamic horizontal space SizedBox.
  Widget horizontalSpace(double factor) => SizedBox(width: w(factor));
}
