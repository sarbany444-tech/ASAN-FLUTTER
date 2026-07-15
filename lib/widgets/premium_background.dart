import 'package:flutter/material.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_decorations.dart';

/// Full-bleed premium navy canvas with soft ambient blobs (glassmorphism base).
class PremiumBackground extends StatelessWidget {
  const PremiumBackground({
    super.key,
    required this.child,
    this.showPattern = true,
  });

  final Widget child;
  final bool showPattern;

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        const DecoratedBox(decoration: BoxDecoration(gradient: AppDecorations.splashGradient)),
        Positioned(
          top: -120,
          right: -80,
          child: _Blob(
            size: 280,
            color: AppColors.primaryGreen.withValues(alpha: 0.28),
          ),
        ),
        Positioned(
          top: 160,
          left: -100,
          child: _Blob(
            size: 220,
            color: AppColors.pink.withValues(alpha: 0.18),
          ),
        ),
        Positioned(
          bottom: -60,
          right: -40,
          child: _Blob(
            size: 200,
            color: AppColors.cyan.withValues(alpha: 0.14),
          ),
        ),
        Positioned(
          bottom: 120,
          left: 40,
          child: _Blob(
            size: 140,
            color: AppColors.accentGold.withValues(alpha: 0.12),
          ),
        ),
        if (showPattern)
          CustomPaint(
            painter: _SoftGridPainter(),
            child: const SizedBox.expand(),
          ),
        child,
      ],
    );
  }
}

class _Blob extends StatelessWidget {
  const _Blob({required this.size, required this.color});

  final double size;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: color,
          boxShadow: [
            BoxShadow(color: color, blurRadius: 80, spreadRadius: 20),
          ],
        ),
      ),
    );
  }
}

class _SoftGridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withValues(alpha: 0.015)
      ..strokeWidth = 1;
    const step = 40.0;
    for (var x = 0.0; x < size.width; x += step) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
    for (var y = 0.0; y < size.height; y += step) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// Responsive content width for phone / tablet / desktop.
class PremiumPage extends StatelessWidget {
  const PremiumPage({
    super.key,
    required this.child,
    this.maxWidth = 560,
    this.padding = const EdgeInsets.all(24),
  });

  final Widget child;
  final double maxWidth;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final horizontal = width >= 1100
            ? 48.0
            : width >= 768
                ? 32.0
                : 0.0;
        return Align(
          alignment: Alignment.topCenter,
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: maxWidth),
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: horizontal).add(padding),
              child: child,
            ),
          ),
        );
      },
    );
  }
}

class PremiumGlassCard extends StatelessWidget {
  const PremiumGlassCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(24),
  });

  final Widget child;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding,
      decoration: AppDecorations.glass(),
      child: child,
    );
  }
}
