import 'dart:math';

import 'package:flutter/material.dart';

import '../app/app_colors.dart';

// Symbols used as background decoration.
const _kSymbols = ['+', '3', '7', '+', '9', '2', '5', '+', '8', '4', '6', '1'];

// Normalized [0..1] (x, y) positions for each symbol.
const _kPositions = <Offset>[
  Offset(0.06, 0.10),
  Offset(0.82, 0.08),
  Offset(0.15, 0.38),
  Offset(0.90, 0.28),
  Offset(0.04, 0.65),
  Offset(0.88, 0.58),
  Offset(0.40, 0.92),
  Offset(0.62, 0.12),
  Offset(0.30, 0.72),
  Offset(0.72, 0.80),
  Offset(0.52, 0.50),
  Offset(0.18, 0.88),
];

// Spark dot positions (normalized).
const _kSparkDots = <Offset>[
  Offset(0.22, 0.18),
  Offset(0.76, 0.20),
  Offset(0.55, 0.78),
  Offset(0.10, 0.52),
  Offset(0.88, 0.44),
  Offset(0.38, 0.06),
  Offset(0.66, 0.94),
  Offset(0.48, 0.30),
];

// Colour pattern for spark dots: alternating cyan / amber.
const _kDotColors = <Color>[
  AppColors.accentCyan,
  Color(0xFFFFD600),
  AppColors.accentCyan,
  Color(0xFFFFD600),
  AppColors.accentCyan,
  Color(0xFFFFD600),
  AppColors.accentCyan,
  Color(0xFFFFD600),
];

/// Subtle dark-arcade atmosphere layer.
///
/// Drop it inside any [Scaffold] body behind your content:
/// ```dart
/// ArcadeBackground(child: myContent)
/// ```
class ArcadeBackground extends StatefulWidget {
  const ArcadeBackground({super.key, required this.child});

  final Widget child;

  @override
  State<ArcadeBackground> createState() => _ArcadeBackgroundState();
}

class _ArcadeBackgroundState extends State<ArcadeBackground>
    with SingleTickerProviderStateMixin {
  late final AnimationController _drift;

  @override
  void initState() {
    super.initState();
    // Very slow 10-second drift so spark dots breathe without feeling busy.
    _drift = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 10),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _drift.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Background glows + dots — behind everything.
        Positioned.fill(
          child: RepaintBoundary(
            child: AnimatedBuilder(
              animation: _drift,
              builder: (context, _) => CustomPaint(
                painter: _ArcadeBgPainter(_drift.value),
              ),
            ),
          ),
        ),
        // Faint symbol overlay — static, no repaint.
        Positioned.fill(
          child: IgnorePointer(
            child: _SymbolOverlay(),
          ),
        ),
        // Actual screen content on top.
        widget.child,
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// CustomPainter for radial glows + animated spark dots
// ---------------------------------------------------------------------------

class _ArcadeBgPainter extends CustomPainter {
  const _ArcadeBgPainter(this.drift);

  final double drift; // 0..1 back-and-forth

  @override
  void paint(Canvas canvas, Size size) {
    _drawGlow(
      canvas,
      size,
      center: Offset(size.width * 0.18, size.height * 0.22),
      radius: size.width * 0.58,
      color: AppColors.primaryPurple,
      alpha: 0.13,
    );
    _drawGlow(
      canvas,
      size,
      center: Offset(size.width * 0.82, size.height * 0.70),
      radius: size.width * 0.48,
      color: AppColors.accentCyan,
      alpha: 0.08,
    );
    _drawGlow(
      canvas,
      size,
      center: Offset(size.width * 0.50, size.height * 0.50),
      radius: size.width * 0.35,
      color: AppColors.primaryPurpleBright,
      alpha: 0.06,
    );

    // Animated spark dots
    for (var i = 0; i < _kSparkDots.length; i++) {
      final pos = _kSparkDots[i];
      final phase = (drift + i * 0.13) % 1.0;
      // y drift ±6 px
      final dy = sin(phase * 2 * pi) * 6.0;
      // Pulse alpha between 0.12 and 0.35
      final alpha = 0.12 + 0.23 * (0.5 + 0.5 * sin(phase * 2 * pi));
      final paint = Paint()
        ..color = _kDotColors[i].withValues(alpha: alpha)
        ..style = PaintingStyle.fill;
      canvas.drawCircle(
        Offset(size.width * pos.dx, size.height * pos.dy + dy),
        3.0,
        paint,
      );
    }
  }

  void _drawGlow(
    Canvas canvas,
    Size size, {
    required Offset center,
    required double radius,
    required Color color,
    required double alpha,
  }) {
    final paint = Paint()
      ..shader = RadialGradient(
        colors: [
          color.withValues(alpha: alpha),
          color.withValues(alpha: 0),
        ],
      ).createShader(Rect.fromCircle(center: center, radius: radius));
    canvas.drawCircle(center, radius, paint);
  }

  @override
  bool shouldRepaint(_ArcadeBgPainter old) => old.drift != drift;
}

// ---------------------------------------------------------------------------
// Static faint symbol overlay
// ---------------------------------------------------------------------------

class _SymbolOverlay extends StatelessWidget {
  const _SymbolOverlay();

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final w = constraints.maxWidth;
        final h = constraints.maxHeight;
        return Stack(
          children: [
            for (var i = 0; i < _kPositions.length; i++)
              Positioned(
                left: _kPositions[i].dx * w - 10,
                top: _kPositions[i].dy * h - 10,
                child: Opacity(
                  opacity: 0.06,
                  child: Text(
                    _kSymbols[i % _kSymbols.length],
                    style: const TextStyle(
                      fontFamily: 'monospace',
                      fontSize: 20,
                      fontWeight: FontWeight.w900,
                      color: AppColors.onSurface,
                    ),
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}
