import 'package:flutter/material.dart';

import 'app_colors.dart';

/// Typography tuned for casual mobile game UI (readable at a glance).
abstract final class AppTextStyles {
  static const TextStyle display = TextStyle(
    fontSize: 34,
    fontWeight: FontWeight.w800,
    height: 1.1,
    letterSpacing: -0.5,
    color: AppColors.onSurface,
  );

  /// App bar / screen titles (consistent arcade header).
  static const TextStyle screenTitle = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.w800,
    height: 1.2,
    color: AppColors.onSurface,
    letterSpacing: -0.2,
  );

  static const TextStyle headline = TextStyle(
    fontSize: 22,
    fontWeight: FontWeight.w700,
    height: 1.2,
    color: AppColors.onSurface,
  );

  static const TextStyle title = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w600,
    height: 1.25,
    color: AppColors.onSurface,
  );

  static const TextStyle body = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w400,
    height: 1.45,
    color: AppColors.onSurface,
  );

  static const TextStyle caption = TextStyle(
    fontSize: 13,
    fontWeight: FontWeight.w500,
    height: 1.3,
    color: AppColors.onSurfaceMuted,
  );

  static const TextStyle tagline = TextStyle(
    fontSize: 17,
    fontWeight: FontWeight.w600,
    height: 1.35,
    color: AppColors.accentCyan,
    letterSpacing: 0.2,
  );

  /// Large digits on the board tiles.
  static const TextStyle numberTile = TextStyle(
    fontSize: 28,
    fontWeight: FontWeight.w800,
    height: 1,
    color: AppColors.tileNumber,
  );

  static const TextStyle hudLabel = TextStyle(
    fontSize: 11,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.45,
    color: AppColors.onSurfaceMuted,
  );

  static const TextStyle hudValue = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w700,
    color: AppColors.onSurface,
  );
}
