import 'package:flutter/material.dart';

import '../app/app_colors.dart';
import '../app/app_spacing.dart';
import '../app/app_text_styles.dart';
import '../models/tile_model.dart';

/// Renders a board cell from [TileModel] with animated interaction states.
class NumberTile extends StatefulWidget {
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
  State<NumberTile> createState() => _NumberTileState();
}

class _NumberTileState extends State<NumberTile>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;

  late Animation<double> _shakeX;
  late Animation<double> _popScale;
  bool _isShaking = false;
  bool _isPopping = false;

  static final _shakeTween = TweenSequence<double>([
    TweenSequenceItem(tween: Tween(begin: 0, end: -7), weight: 1),
    TweenSequenceItem(tween: Tween(begin: -7, end: 7), weight: 2),
    TweenSequenceItem(tween: Tween(begin: 7, end: -5), weight: 2),
    TweenSequenceItem(tween: Tween(begin: -5, end: 5), weight: 2),
    TweenSequenceItem(tween: Tween(begin: 5, end: 0), weight: 1),
  ]);

  static final _popTween = TweenSequence<double>([
    TweenSequenceItem(tween: Tween(begin: 1.0, end: 1.15), weight: 3),
    TweenSequenceItem(tween: Tween(begin: 1.15, end: 0.96), weight: 2),
    TweenSequenceItem(tween: Tween(begin: 0.96, end: 1.0), weight: 1),
  ]);

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 380),
    );
    _shakeX = _shakeTween.animate(_ctrl);
    _popScale = _popTween.animate(_ctrl);
  }

  @override
  void didUpdateWidget(NumberTile old) {
    super.didUpdateWidget(old);
    if (old.tile.state != widget.tile.state) {
      _ctrl.stop();
      _ctrl.reset();
      _isShaking = false;
      _isPopping = false;

      if (widget.tile.state == TileState.mistake) {
        _isShaking = true;
        _ctrl.forward().then((_) {
          if (mounted) setState(() => _isShaking = false);
        });
      } else if (widget.tile.state == TileState.correct) {
        _isPopping = true;
        _ctrl.forward().then((_) {
          if (mounted) setState(() => _isPopping = false);
        });
      }
    }
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isMultiplier = widget.tile.isScoreMultiplierTile;
    final mult = widget.tile.scoreMultiplier;

    final Color bg;
    final Color fg;
    switch (widget.tile.state) {
      case TileState.disabled:
        bg = AppColors.surfaceContainerHighest;
        fg = AppColors.onSurfaceMuted.withValues(alpha: 0.85);
      case TileState.mistake:
        bg = AppColors.tileMistakeFill;
        fg = Colors.white;
      case TileState.correct:
        bg = AppColors.tileSuccessFill;
        fg = Colors.white;
      case TileState.selected:
        bg = AppColors.accentCyan;
        fg = AppColors.background;
      case TileState.normal:
        bg = isMultiplier
            ? AppColors.tileFace
            : AppColors.tileFace;
        fg = AppColors.tileNumber;
    }

    final style = AppTextStyles.numberTile.copyWith(color: fg);
    final borderW =
        widget.tile.isSelected || widget.tile.state == TileState.mistake
            ? 2.0
            : isMultiplier
            ? 1.5
            : 1.0;
    final borderColor = switch (widget.tile.state) {
      TileState.selected => isMultiplier
          ? AppColors.accentAmber
          : AppColors.accentCyanDim,
      TileState.mistake => AppColors.tileMistakeBorder,
      TileState.correct => AppColors.accentCyan,
      _ => isMultiplier
          ? AppColors.accentAmber.withValues(alpha: 0.75)
          : AppColors.outline.withValues(alpha: 0.22),
    };

    final semanticsLabel = isMultiplier
        ? '${widget.tile.value}, score multiplier ${mult}x'
        : '${widget.tile.value}';

    return Semantics(
      label: semanticsLabel,
      button: true,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: widget.tile.state == TileState.disabled ? null : widget.onTap,
          borderRadius: BorderRadius.circular(AppSpacing.radiusTile),
          splashColor: AppColors.accentCyan.withValues(alpha: 0.2),
          highlightColor: AppColors.primaryPurple.withValues(alpha: 0.08),
          child: AnimatedBuilder(
            animation: _ctrl,
            builder: (context, child) {
              double dx = 0;
              double popS = 1.0;
              if (_isShaking) dx = _shakeX.value;
              if (_isPopping) popS = _popScale.value;

              return Transform.translate(
                offset: Offset(dx, 0),
                child: Transform.scale(
                  scale: popS,
                  child: child,
                ),
              );
            },
            child: AnimatedScale(
              scale: widget.tile.isSelected ? 1.04 : 1.0,
              duration: const Duration(milliseconds: 120),
              curve: Curves.easeOutCubic,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                curve: Curves.easeOutCubic,
                decoration: BoxDecoration(
                  color: bg,
                  borderRadius: BorderRadius.circular(AppSpacing.radiusTile),
                  border: Border.all(color: borderColor, width: borderW),
                  boxShadow: [
                    if (isMultiplier && widget.tile.state == TileState.normal)
                      BoxShadow(
                        color: AppColors.accentAmber.withValues(alpha: 0.35),
                        blurRadius: 10,
                        offset: const Offset(0, 2),
                      )
                    else if (widget.tile.state == TileState.selected &&
                        isMultiplier)
                      BoxShadow(
                        color: AppColors.accentAmber.withValues(alpha: 0.5),
                        blurRadius: 14,
                        offset: const Offset(0, 2),
                      )
                    else if (widget.tile.state == TileState.selected)
                      BoxShadow(
                        color: AppColors.accentCyan.withValues(alpha: 0.38),
                        blurRadius: 14,
                        offset: const Offset(0, 3),
                      )
                    else
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.2),
                        blurRadius: 5,
                        offset: const Offset(0, 2),
                      ),
                  ],
                ),
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Center(child: Text('${widget.tile.value}', style: style)),
                    if (isMultiplier)
                      Positioned(
                        top: 3,
                        right: 3,
                        child: _MultiplierBadge(multiplier: mult),
                      ),
                    if (widget.showMatchCheck && widget.tile.isSelected)
                      Positioned(
                        top: 4,
                        left: 4,
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
        ),
      ),
    );
  }
}

class _MultiplierBadge extends StatelessWidget {
  const _MultiplierBadge({required this.multiplier});

  final int multiplier;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.accentAmber,
            AppColors.accentAmber.withValues(alpha: 0.85),
          ],
        ),
        borderRadius: BorderRadius.circular(7),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.7),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.accentAmber.withValues(alpha: 0.65),
            blurRadius: 6,
          ),
        ],
      ),
      child: Text(
        '${multiplier}x',
        style: AppTextStyles.caption.copyWith(
          color: AppColors.background,
          fontSize: 11,
          fontWeight: FontWeight.w900,
          height: 1.0,
          letterSpacing: 0.3,
        ),
      ),
    );
  }
}
