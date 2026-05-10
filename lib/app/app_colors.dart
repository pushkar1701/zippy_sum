import 'package:flutter/material.dart';

/// Dark arcade palette + electric purple + cyan accents (Stitch direction).
abstract final class AppColors {
  static const Color background = Color(0xFF13121B);
  static const Color surface = Color(0xFF1B1B24);
  static const Color surfaceContainer = Color(0xFF1F1F28);
  static const Color surfaceContainerHigh = Color(0xFF2A2933);
  static const Color surfaceContainerHighest = Color(0xFF35343E);

  static const Color onSurface = Color(0xFFE4E1EE);
  static const Color onSurfaceMuted = Color(0xFFC7C4D8);

  static const Color primaryPurple = Color(0xFF4F46E5);
  static const Color primaryPurpleBright = Color(0xFF7C3AED);
  static const Color accentCyan = Color(0xFF4CD7F6);
  static const Color accentCyanDim = Color(0xFF03B5D3);

  static const Color tileFace = Color(0xFFFFFFFF);
  static const Color tileNumber = Color(0xFF13121B);

  static const Color outline = Color(0xFF464555);
  static const Color outlineBright = Color(0xFF918FA1);

  static const Color error = Color(0xFFFFB4AB);

  /// Primary CTA gradient endpoints.
  static const List<Color> primaryButtonGradient = [
    primaryPurple,
    primaryPurpleBright,
  ];
}
