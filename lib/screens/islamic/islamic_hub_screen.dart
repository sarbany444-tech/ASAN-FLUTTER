import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_decorations.dart';
import '../../l10n/app_localizations.dart';
import '../../widgets/naseem_app_bar.dart';
import '../../widgets/premium_background.dart';
import '../../widgets/section_header.dart';

class IslamicHubScreen extends StatelessWidget {
  const IslamicHubScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    final features = [
      _FeatureItem(Icons.menu_book_rounded, l10n.quran, '/section/quran_recitation'),
      _FeatureItem(Icons.format_quote_rounded, l10n.hadith, '/section/hadith'),
      _FeatureItem(Icons.school_rounded, l10n.lectures, '/section/lectures'),
      _FeatureItem(Icons.music_note_rounded, l10n.nasheed, '/section/nasheed'),
      _FeatureItem(Icons.notifications_active_rounded, l10n.reminders, '/daily-reminder'),
      _FeatureItem(Icons.access_time_rounded, l10n.prayerTimes, '/prayer-times'),
      _FeatureItem(Icons.explore_rounded, l10n.qibla, '/qibla'),
      _FeatureItem(Icons.calendar_month_rounded, l10n.islamicCalendar, '/islamic-calendar'),
      _FeatureItem(Icons.auto_stories_rounded, l10n.dailyQuranVerse, '/daily-quran'),
      _FeatureItem(Icons.book_rounded, l10n.dailyHadith, '/daily-hadith'),
    ];

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: NaseemAppBar(title: l10n.islamic),
      body: PremiumBackground(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _DailyBanner(l10n: l10n),
            const SizedBox(height: 20),
            const SectionHeader(title: 'Islamic Tools & Content'),
            ...features.map(
              (f) => Container(
                margin: const EdgeInsets.only(bottom: 8),
                decoration: AppDecorations.glass(opacity: 0.78),
                child: ListTile(
                  shape: RoundedRectangleBorder(
                    borderRadius:
                        BorderRadius.circular(AppDecorations.radiusXl),
                  ),
                  leading: Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      gradient: AppDecorations.purplePinkGradient,
                      borderRadius:
                          BorderRadius.circular(AppDecorations.radiusMd),
                    ),
                    child: Icon(f.icon, color: Colors.white, size: 22),
                  ),
                  title: Text(
                    f.title,
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                  trailing: const Icon(Icons.chevron_right_rounded,
                      color: AppColors.textSecondary),
                  onTap: () => context.push(f.route),
                ),
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}

class _FeatureItem {
  const _FeatureItem(this.icon, this.title, this.route);
  final IconData icon;
  final String title;
  final String route;
}

class _DailyBanner extends StatelessWidget {
  const _DailyBanner({required this.l10n});
  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: AppDecorations.brandGradient,
        borderRadius: BorderRadius.circular(AppDecorations.radiusXl),
        boxShadow: AppDecorations.goldGlow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.appTitle,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 13,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'بِسْمِ اللَّهِ الرَّحْمَٰنِ الرَّحِيمِ',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                ),
            textDirection: TextDirection.rtl,
          ),
          const SizedBox(height: 8),
          Text(
            'In the name of Allah, the Most Gracious, the Most Merciful',
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.85),
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }
}
