import 'package:flutter/material.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_decorations.dart';

/// Naseem brand mark — wind/breeze motif with Islamic green & gold.
class NaseemLogo extends StatelessWidget {
  const NaseemLogo({
    super.key,
    this.size = 120,
    this.showGlow = true,
    this.iconSize,
  });

  final double size;
  final bool showGlow;
  final double? iconSize;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.white, Color(0xFFF0F7F0)],
        ),
        boxShadow: showGlow ? AppDecorations.goldGlow : null,
        border: Border.all(
          color: AppColors.accentGold.withValues(alpha: 0.5),
          width: 2,
        ),
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Decorative ring
          Container(
            width: size * 0.78,
            height: size * 0.78,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: AppColors.primaryGreen.withValues(alpha: 0.15),
                width: 1.5,
              ),
            ),
          ),
          Icon(
            Icons.air_rounded,
            size: iconSize ?? size * 0.45,
            color: AppColors.primaryGreen,
          ),
          Positioned(
            bottom: size * 0.22,
            child: Container(
              width: size * 0.12,
              height: 3,
              decoration: BoxDecoration(
                gradient: AppDecorations.goldGradient,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class NaseemWordmark extends StatelessWidget {
  const NaseemWordmark({
    super.key,
    this.light = false,
    this.showArabic = true,
  });

  final bool light;
  final bool showArabic;

  @override
  Widget build(BuildContext context) {
    final titleColor = light ? AppColors.white : AppColors.primaryGreenDark;
    final subtitleColor =
        light ? AppColors.accentGoldLight : AppColors.textSecondary;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (showArabic)
          Text(
            'نسيم',
            style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                  color: light ? AppColors.accentGoldLight : AppColors.primaryGreen,
                  fontSize: 28,
                ),
          ),
        Text(
          'Naseem',
          style: Theme.of(context).textTheme.displayLarge?.copyWith(
                color: titleColor,
                letterSpacing: 1.2,
              ),
        ),
        const SizedBox(height: 4),
        Text(
          'Beneficial Islamic Content',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: subtitleColor,
                letterSpacing: 0.3,
              ),
        ),
      ],
    );
  }
}
