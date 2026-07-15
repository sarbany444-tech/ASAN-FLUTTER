import 'package:flutter/material.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_decorations.dart';

class NaseemButton extends StatelessWidget {
  const NaseemButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.loading = false,
    this.outlined = false,
    this.icon,
    this.expand = true,
  });

  final String label;
  final VoidCallback? onPressed;
  final bool loading;
  final bool outlined;
  final IconData? icon;
  final bool expand;

  @override
  Widget build(BuildContext context) {
    final child = loading
        ? const SizedBox(
            height: 22,
            width: 22,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: Colors.white,
            ),
          )
        : Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (icon != null) ...[
                Icon(icon, size: 20),
                const SizedBox(width: 8),
              ],
              Text(
                label,
                style: const TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 15,
                  letterSpacing: 0.2,
                ),
              ),
            ],
          );

    if (outlined) {
      return SizedBox(
        width: expand ? double.infinity : null,
        height: 54,
        child: OutlinedButton(
          onPressed: loading ? null : onPressed,
          style: OutlinedButton.styleFrom(
            foregroundColor: AppColors.textPrimary,
            side: BorderSide(
              color: AppColors.primaryGreen.withValues(alpha: 0.55),
              width: 1.5,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppDecorations.radiusXl),
            ),
          ),
          child: child,
        ),
      );
    }

    return SizedBox(
      width: expand ? double.infinity : null,
      height: 54,
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: onPressed == null || loading
              ? null
              : AppDecorations.brandGradient,
          color: onPressed == null || loading
              ? AppColors.primaryGreen.withValues(alpha: 0.35)
              : null,
          borderRadius: BorderRadius.circular(AppDecorations.radiusXl),
          boxShadow: onPressed == null || loading
              ? null
              : [
                  BoxShadow(
                    color: AppColors.pink.withValues(alpha: 0.35),
                    blurRadius: 22,
                    offset: const Offset(0, 10),
                  ),
                ],
        ),
        child: ElevatedButton(
          onPressed: loading ? null : onPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.transparent,
            shadowColor: Colors.transparent,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppDecorations.radiusXl),
            ),
          ),
          child: child,
        ),
      ),
    );
  }
}
