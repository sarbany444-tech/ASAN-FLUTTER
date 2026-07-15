import 'package:flutter/material.dart';
import 'app_colors.dart';

/// Shared visual tokens — glass, gradients, radii, shadows.
class AppDecorations {
  AppDecorations._();

  static const double radiusSm = 12;
  static const double radiusMd = 16;
  static const double radiusLg = 20;
  static const double radiusXl = 24;
  static const double radiusFull = 999;

  static const LinearGradient brandGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      AppColors.accentGold,
      AppColors.pink,
      AppColors.primaryGreen,
    ],
  );

  static const LinearGradient greenGradient = brandGradient;

  static const LinearGradient goldGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      AppColors.accentGoldLight,
      AppColors.accentGold,
      AppColors.pink,
    ],
  );

  static const LinearGradient purplePinkGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [AppColors.primaryGreen, AppColors.pink],
  );

  static const LinearGradient cyanPurpleGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [AppColors.cyan, AppColors.primaryGreen],
  );

  static const LinearGradient splashGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFF070B1A),
      Color(0xFF12103A),
      Color(0xFF1A0F2E),
      Color(0xFF070B1A),
    ],
    stops: [0.0, 0.35, 0.7, 1.0],
  );

  static const LinearGradient heroGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFF1A1448),
      Color(0xFF121830),
      Color(0xFF0E1428),
    ],
  );

  static List<BoxShadow> get softShadow => [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.45),
          blurRadius: 28,
          offset: const Offset(0, 14),
        ),
        BoxShadow(
          color: AppColors.primaryGreen.withValues(alpha: 0.08),
          blurRadius: 24,
          offset: const Offset(0, 0),
        ),
      ];

  static List<BoxShadow> get cardShadow => softShadow;

  static List<BoxShadow> get goldGlow => [
        BoxShadow(
          color: AppColors.pink.withValues(alpha: 0.35),
          blurRadius: 28,
          spreadRadius: 0,
          offset: const Offset(0, 10),
        ),
      ];

  static List<BoxShadow> get purpleGlow => [
        BoxShadow(
          color: AppColors.primaryGreen.withValues(alpha: 0.35),
          blurRadius: 24,
          spreadRadius: 0,
        ),
      ];

  static BoxDecoration card({Color? color}) => BoxDecoration(
        color: color ?? AppColors.navyCard.withValues(alpha: 0.85),
        borderRadius: BorderRadius.circular(radiusXl),
        boxShadow: softShadow,
        border: Border.all(color: AppColors.border),
      );

  static BoxDecoration glass({double opacity = 0.72}) => BoxDecoration(
        color: AppColors.navyCard.withValues(alpha: opacity),
        borderRadius: BorderRadius.circular(radiusXl),
        border: Border.all(color: AppColors.border),
        boxShadow: softShadow,
      );

  static BoxDecoration glassPill({bool active = false}) => BoxDecoration(
        gradient: active ? purplePinkGradient : null,
        color: active ? null : AppColors.navyLight.withValues(alpha: 0.7),
        borderRadius: BorderRadius.circular(radiusFull),
        border: Border.all(
          color: active ? AppColors.borderGlow : AppColors.border,
        ),
        boxShadow: active ? purpleGlow : null,
      );

  static BoxDecoration ambientBackground() => const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xFF0A0F22),
            AppColors.navy,
            Color(0xFF0A0718),
          ],
        ),
      );
}
