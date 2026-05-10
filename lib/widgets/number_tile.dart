import 'package:flutter/material.dart';

import '../app/app_colors.dart';
import '../app/app_spacing.dart';
import '../app/app_text_styles.dart';
import '../models/tile_model.dart';

/// Renders a board cell from [TileModel] (state comes from game logic).
class NumberTile extends StatelessWidget {
  const NumberTile({
    super.key,
    required this.tile,
    this.onTap,
  });

  final TileModel tile;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final Color bg;
    final Color fg;
    switch (tile.state) {
      case TileState.disabled:
        bg = AppColors.surfaceContainerHighest;
        fg = AppColors.onSurfaceMuted;
      case TileState.mistake:
        bg = AppColors.error.withValues(alpha: 0.35);
        fg = AppColors.onSurface;
      case TileState.correct:
        bg = AppColors.accentCyan.withValues(alpha: 0.45);
        fg = AppColors.background;
      case TileState.selected:
        bg = AppColors.accentCyan;
        fg = AppColors.background;
      case TileState.normal:
        bg = AppColors.tileFace;
        fg = AppColors.tileNumber;
    }

    final style = AppTextStyles.numberTile.copyWith(color: fg);
    final borderW = tile.isSelected || tile.state == TileState.mistake ? 2.0 : 1.0;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: tile.state == TileState.disabled ? null : onTap,
        borderRadius: BorderRadius.circular(AppSpacing.radiusTile),
        child: Ink(
          decoration: BoxDecoration(
            color: bg,
            borderRadius: BorderRadius.circular(AppSpacing.radiusTile),
            border: Border.all(
              color: switch (tile.state) {
                TileState.selected => AppColors.accentCyanDim,
                TileState.mistake => AppColors.error,
                TileState.correct => AppColors.accentCyan,
                _ => AppColors.outline.withValues(alpha: 0.2),
              },
              width: borderW,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.25),
                blurRadius: tile.isSelected ? 10 : 6,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Center(
            child: Text('${tile.value}', style: style),
          ),
        ),
      ),
    );
  }
}
