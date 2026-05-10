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
    this.showMatchCheck = false,
  });

  final TileModel tile;
  final VoidCallback? onTap;
  final bool showMatchCheck;

  @override
  Widget build(BuildContext context) {
    final Color bg;
    final Color fg;
    switch (tile.state) {
      case TileState.disabled:
        bg = AppColors.surfaceContainerHighest;
        fg = AppColors.onSurfaceMuted;
      case TileState.mistake:
        bg = AppColors.error.withValues(alpha: 0.4);
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
    final borderW = tile.isSelected || tile.state == TileState.mistake
        ? 2.0
        : 1.0;
    final borderColor = switch (tile.state) {
      TileState.selected => AppColors.accentCyanDim,
      TileState.mistake => AppColors.error,
      TileState.correct => AppColors.accentCyan,
      _ => AppColors.outline.withValues(alpha: 0.2),
    };

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: tile.state == TileState.disabled ? null : onTap,
        borderRadius: BorderRadius.circular(AppSpacing.radiusTile),
        child: AnimatedScale(
          scale: tile.isSelected ? 1.04 : 1.0,
          duration: const Duration(milliseconds: 140),
          curve: Curves.easeOutBack,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeOutCubic,
            decoration: BoxDecoration(
              color: bg,
              borderRadius: BorderRadius.circular(AppSpacing.radiusTile),
              border: Border.all(color: borderColor, width: borderW),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.25),
                  blurRadius: tile.isSelected ? 12 : 6,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                Center(child: Text('${tile.value}', style: style)),
                if (showMatchCheck && tile.isSelected)
                  Positioned(
                    top: 4,
                    right: 4,
                    child: Container(
                      padding: const EdgeInsets.all(2),
                      decoration: BoxDecoration(
                        color: AppColors.accentCyan,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.35),
                            blurRadius: 4,
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.check_rounded,
                        size: 14,
                        color: AppColors.tileNumber,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
