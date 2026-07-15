import 'package:flutter/material.dart';
import '../../core/constants/content_policy.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_decorations.dart';
import '../../l10n/app_localizations.dart';
import '../../widgets/naseem_app_bar.dart';
import '../../widgets/premium_background.dart';

class CommunityGuidelinesScreen extends StatelessWidget {
  const CommunityGuidelinesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    const allowed = [
      'Quran recitation and memorization lessons',
      'Tafsir and Quran explanations',
      'Hadith and Sunnah teachings',
      'Islamic lectures and reminders',
      'Islamic nasheeds (vocals only, no instruments)',
      'Arabic language learning',
      'Islamic history and education',
      'Islamic education for children',
      'Charity and community awareness',
      'Educational content consistent with Islamic values',
    ];

    const prohibited = [
      'Music videos and entertainment unrelated to Islamic education',
      'Dancing videos',
      'Inappropriate clothing or behavior',
      'Violence and harmful content',
      'Gambling, alcohol, or drug-related content',
      'Dating or adult content',
      'Offensive language and hate speech',
      'Political propaganda',
      'Any content violating Islamic values',
    ];

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: NaseemAppBar(title: l10n.communityGuidelines),
      body: PremiumBackground(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: AppDecorations.glass(opacity: 0.85),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.about,
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Naseem is dedicated exclusively to beneficial Islamic content. '
                    'All uploads are analyzed by AI before publishing.',
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: AppColors.textSecondary,
                          height: 1.5,
                        ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            _SectionHeader(
              title: l10n.allowedContent,
              icon: Icons.check_circle_rounded,
              color: AppColors.success,
            ),
            ...allowed.map((item) => _GuidelineItem(text: item, allowed: true)),
            const SizedBox(height: 20),
            _SectionHeader(
              title: l10n.prohibitedContent,
              icon: Icons.cancel_rounded,
              color: AppColors.error,
            ),
            ...prohibited.map((item) => _GuidelineItem(text: item, allowed: false)),
            const SizedBox(height: 20),
            _SectionHeader(
              title: l10n.contentPolicy,
              icon: Icons.category_rounded,
              color: AppColors.primaryGreen,
            ),
            Container(
              margin: const EdgeInsets.only(top: 8),
              decoration: AppDecorations.glass(opacity: 0.78),
              child: Column(
                children: ContentPolicy.allowedCategories.map(
                  (cat) => ListTile(
                    dense: true,
                    leading: Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: AppColors.success.withValues(alpha: 0.15),
                        borderRadius:
                            BorderRadius.circular(AppDecorations.radiusSm),
                      ),
                      child: const Icon(Icons.check_rounded,
                          size: 16, color: AppColors.success),
                    ),
                    title: Text(ContentPolicy.categoryLabels[cat] ?? cat),
                  ),
                ).toList(),
              ),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.warning.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(AppDecorations.radiusXl),
                border: Border.all(
                  color: AppColors.warning.withValues(alpha: 0.35),
                ),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.warning_amber_rounded,
                      color: AppColors.warning, size: 22),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Violations result in strikes. 3 strikes = suspension. '
                      '5 strikes = permanent ban.',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            height: 1.45,
                          ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({
    required this.title,
    required this.icon,
    required this.color,
  });

  final String title;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(AppDecorations.radiusSm),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 10),
          Text(
            title,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
          ),
        ],
      ),
    );
  }
}

class _GuidelineItem extends StatelessWidget {
  const _GuidelineItem({required this.text, required this.allowed});

  final String text;
  final bool allowed;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, top: 6, bottom: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 22,
            height: 22,
            decoration: BoxDecoration(
              color: (allowed ? AppColors.success : AppColors.error)
                  .withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            child: Icon(
              allowed ? Icons.add_rounded : Icons.remove_rounded,
              size: 14,
              color: allowed ? AppColors.success : AppColors.error,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    height: 1.4,
                  ),
            ),
          ),
        ],
      ),
    );
  }
}
