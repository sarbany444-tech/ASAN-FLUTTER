import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../core/theme/app_colors.dart';
import 'premium_background.dart';

/// Auth & onboarding background — now maps to the premium dark canvas.
class IslamicPatternBackground extends StatelessWidget {
  const IslamicPatternBackground({
    super.key,
    required this.child,
    this.showGradient = true,
  });

  final Widget child;
  final bool showGradient;

  @override
  Widget build(BuildContext context) {
    if (!showGradient) {
      return Stack(
        fit: StackFit.expand,
        children: [
          CustomPaint(painter: _PatternPainter()),
          child,
        ],
      );
    }
    return PremiumBackground(
      child: Stack(
        fit: StackFit.expand,
        children: [
          CustomPaint(painter: _PatternPainter()),
          child,
        ],
      ),
    );
  }
}

class _PatternPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.primaryGreen.withValues(alpha: 0.045)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;

    const spacing = 56.0;
    for (var x = 0.0; x < size.width + spacing; x += spacing) {
      for (var y = 0.0; y < size.height + spacing; y += spacing) {
        _drawStar(canvas, Offset(x, y), 9, paint);
      }
    }
  }

  void _drawStar(Canvas canvas, Offset center, double radius, Paint paint) {
    const points = 8;
    final path = Path();
    for (var i = 0; i < points * 2; i++) {
      final r = i.isEven ? radius : radius * 0.4;
      final angle = (i * math.pi / points) - math.pi / 2;
      final x = center.dx + r * math.cos(angle);
      final y = center.dy + r * math.sin(angle);
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    path.close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
