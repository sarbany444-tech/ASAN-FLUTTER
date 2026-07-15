import 'package:flutter/material.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_decorations.dart';
import 'naseem_button.dart';

/// Shared empty / loading / error surfaces for consistent premium UX.
class PremiumLoading extends StatelessWidget {
  const PremiumLoading({super.key, this.message});

  final String? message;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 64,
            height: 64,
            padding: const EdgeInsets.all(16),
            decoration: AppDecorations.glass(opacity: 0.9),
            child: const CircularProgressIndicator(
              strokeWidth: 2.5,
              color: AppColors.primaryGreen,
            ),
          ),
          if (message != null) ...[
            const SizedBox(height: 16),
            Text(
              message!,
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
          ],
        ],
      ),
    );
  }
}

class PremiumEmptyState extends StatelessWidget {
  const PremiumEmptyState({
    super.key,
    required this.title,
    this.subtitle,
    this.icon = Icons.inbox_outlined,
    this.actionLabel,
    this.onAction,
  });

  final String title;
  final String? subtitle;
  final IconData icon;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 88,
              height: 88,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: AppDecorations.purplePinkGradient,
                boxShadow: AppDecorations.purpleGlow,
              ),
              child: Icon(icon, size: 40, color: Colors.white),
            ),
            const SizedBox(height: 24),
            Text(
              title,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            if (subtitle != null) ...[
              const SizedBox(height: 10),
              Text(
                subtitle!,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ],
            if (actionLabel != null && onAction != null) ...[
              const SizedBox(height: 24),
              SizedBox(
                width: 200,
                child: NaseemButton(
                  label: actionLabel!,
                  onPressed: onAction,
                  expand: false,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class PremiumErrorState extends StatelessWidget {
  const PremiumErrorState({
    super.key,
    required this.message,
    this.onRetry,
  });

  final String message;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 88,
              height: 88,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.error.withValues(alpha: 0.15),
                border: Border.all(color: AppColors.error.withValues(alpha: 0.35)),
              ),
              child: const Icon(Icons.error_outline_rounded, size: 40, color: AppColors.error),
            ),
            const SizedBox(height: 24),
            Text(
              'Something went wrong',
              style: Theme.of(context).textTheme.headlineMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 10),
            Text(
              message,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            if (onRetry != null) ...[
              const SizedBox(height: 24),
              NaseemButton(
                label: 'Try again',
                icon: Icons.refresh_rounded,
                onPressed: onRetry,
                expand: false,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
