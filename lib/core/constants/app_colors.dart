import 'package:flutter/material.dart';

/// App color palette matching the UI design specifications.
/// Dominant mint/teal theme with warm coral accents for interactive elements.
abstract final class AppColors {
  // Primary Teal Palette
  static const Color primaryTeal = Color(0xFF339384);
  static const Color primaryTealDark = Color(0xFF247366);
  static const Color primaryTealLight = Color(0xFF4BB4A4);
  static const Color background = Color(0xFF318F80);
  static const Color surface = Color(0xFF3FA192);

  // Card and Container Surfaces
  static const Color cardSurface = Color(0xFF4BAEA0);
  static const Color cardSurfaceLight = Color(0xFF62BCB0);
  static const Color inputBackground = Color(0xFF5AB6A9);

  // Coral / Salmon Accents
  static const Color accentCoral = Color(0xFFDC6C63);
  static const Color accentCoralDark = Color(0xFFC4574E);
  static const Color accentCoralLight = Color(0xFFE8837A);

  // Text and Icon Colors
  static const Color textLight = Color(0xFFFFFFFF);
  static const Color textSecondary = Color(0xFFBCEAE3);
  static const Color textMuted = Color(0xFF75BEB2);
  static const Color textDark = Color(0xFF174C43);

  // Functional & Status
  static const Color iconWhite = Color(0xFFFFFFFF);
  static const Color iconInactive = Color(0xFF88C9BF);
  static const Color divider = Color(0x33FFFFFF);
  static const Color shadow = Color(0x2A000000);
}
