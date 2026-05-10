import 'package:flutter/material.dart';

import '../app/app_colors.dart';
import '../app/app_spacing.dart';
import '../models/tile_model.dart';

class NumberTile extends StatelessWidget {
  const NumberTile({
    super.key,
    required this.tile,
    this.selected = false,
    this.onTap,
  });

  final TileModel tile;
  final bool selected;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: selected ? AppColors.accentCyan : AppColors.tileFace,
      borderRadius: BorderRadius.circular(AppSpacing.sm),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppSpacing.sm),
        child: Center(
          child: Text(
            '${tile.value}',
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: AppColors.surface,
            ),
          ),
        ),
      ),
    );
  }
}
