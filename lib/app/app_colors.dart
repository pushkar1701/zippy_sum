import 'package:flutter/material.dart';

/// Arcade Kinetic v1 — dark charcoal, violet primary, electric cyan secondary.
abstract final class AppColors {
  static const Color background = Color(0xFF212529);
  static const Color surface = Color(0xFF2C3038);
  static const Color surfaceContainer = Color(0xFF343A40);
  static const Color surfaceContainerHigh = Color(0xFF3D444B);
  static const Color surfaceContainerHighest = Color(0xFF495057);

  static const Color onSurface = Color(0xFFF8F9FA);
  static const Color onSurfaceMuted = Color(0xFFADB5BD);

  static const Color primaryPurple = Color(0xFF6F42C1);
  static const Color primaryPurpleBright = Color(0xFF8B5CF6);
  static const Color accentCyan = Color(0xFF00BFFF);
  static const Color accentCyanDim = Color(0xFF0099CC);

  static const Color warningOrange = Color(0xFFFF9900);
  static const Color warningMuted = Color(0xFFFFB366);

  static const Color tileFace = Color(0xFFF5F6F8);
  static const Color tileNumber = Color(0xFF1A1D21);

  static const Color tileMistakeFill = Color(0xFF6B2A2A);
  static const Color tileMistakeBorder = Color(0xFFFF5252);
  static const Color tileSuccessFill = Color(0xFF1FA88A);
  static const Color timerUrgent = Color(0xFFFF6B6B);

  static const Color outline = Color(0xFF495057);
  static const Color outlineBright = Color(0xFF868E96);

  static const Color error = Color(0xFFFF6B6B);

  static const Color accentAmber = Color(0xFFFFD600);

  /// Primary CTA gradient endpoints.
  static const List<Color> primaryButtonGradient = [
    primaryPurple,
    primaryPurpleBright,
  ];
}
