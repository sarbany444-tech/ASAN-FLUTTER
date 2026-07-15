import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../core/constants/content_policy.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_decorations.dart';
import '../../l10n/app_localizations.dart';
import '../../providers/feed_provider.dart';
import '../../widgets/naseem_app_bar.dart';
import '../../widgets/premium_background.dart';
import '../../widgets/premium_states.dart';
import '../../widgets/section_header.dart';

class ExploreScreen extends StatefulWidget {
  const ExploreScreen({super.key});

  @override
  State<ExploreScreen> createState() => _ExploreScreenState();
}

class _ExploreScreenState extends State<ExploreScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<FeedProvider>().loadTrending();
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final feed = context.watch<FeedProvider>();
    final trending = feed.trendingVideos;

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: NaseemAppBar(title: l10n.explore),
      body: PremiumBackground(
        child: feed.trendingVideos.isEmpty && feed.isLoading
            ? const PremiumLoading(message: 'Loading explore…')
            : CustomScrollView(
                slivers: [
                  if (trending.isNotEmpty) ...[
                    const SliverToBoxAdapter(
                      child: SectionHeader(title: 'Trending Islamic Content'),
                    ),
                    SliverToBoxAdapter(
                      child: SizedBox(
                        height: 180,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          itemCount: trending.length,
                          itemBuilder: (_, i) {
                            final v = trending[i];
                            return Container(
                              width: 130,
                              margin: const EdgeInsets.only(right: 10),
                              decoration: AppDecorations.glass(opacity: 0.82),
                              clipBehavior: Clip.antiAlias,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  Expanded(
                                    child: Container(
                                      decoration: const BoxDecoration(
                                        gradient: AppDecorations.purplePinkGradient,
                                      ),
                                      child: v.thumbnailUrl != null
                                          ? Image.network(
                                              v.thumbnailUrl!,
                                              fit: BoxFit.cover,
                                            )
                                          : const Center(
                                              child: Icon(
                                                Icons.play_circle_outline_rounded,
                                                color: Colors.white70,
                                                size: 36,
                                              ),
                                            ),
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.all(10),
                                    child: Text(
                                      v.title,
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                        color: AppColors.textPrimary,
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                  ],
                  const SliverToBoxAdapter(
                    child: SectionHeader(title: 'Browse by Category'),
                  ),
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                    sliver: SliverGrid(
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        crossAxisSpacing: 12,
                        mainAxisSpacing: 12,
                        childAspectRatio: 1.05,
                      ),
                      delegate: SliverChildBuilderDelegate(
                        (_, index) {
                          final category =
                              ContentPolicy.allowedCategories[index];
                          final label =
                              ContentPolicy.categoryLabels[category] ?? category;
                          return _CategoryCard(
                            label: label,
                            icon: _categoryIcon(category),
                            onTap: () => context.push('/section/$category'),
                          );
                        },
                        childCount: ContentPolicy.allowedCategories.length,
                      ),
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  IconData _categoryIcon(String category) {
    return switch (category) {
      'quran_recitation' => Icons.menu_book_rounded,
      'quran_memorization' => Icons.psychology_rounded,
      'tafsir' => Icons.auto_stories_rounded,
      'hadith' => Icons.format_quote_rounded,
      'lectures' => Icons.school_rounded,
      'reminders' => Icons.notifications_active_rounded,
      'nasheed' => Icons.music_note_rounded,
      'arabic_learning' => Icons.translate_rounded,
      'islamic_history' => Icons.history_edu_rounded,
      'children_education' => Icons.child_care_rounded,
      'charity' => Icons.volunteer_activism_rounded,
      _ => Icons.lightbulb_rounded,
    };
  }
}

class _CategoryCard extends StatelessWidget {
  const _CategoryCard({
    required this.label,
    required this.icon,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final VoidCallback onTap;

  static const _gradients = [
    AppDecorations.brandGradient,
    AppDecorations.purplePinkGradient,
    AppDecorations.cyanPurpleGradient,
    AppDecorations.goldGradient,
  ];

  @override
  Widget build(BuildContext context) {
    final gradient = _gradients[label.hashCode.abs() % _gradients.length];

    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          gradient: gradient,
          borderRadius: BorderRadius.circular(AppDecorations.radiusXl),
          boxShadow: AppDecorations.softShadow,
        ),
        child: Stack(
          children: [
            Positioned(
              top: -16,
              right: -16,
              child: Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withValues(alpha: 0.12),
                ),
              ),
            ),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.18),
                    borderRadius:
                        BorderRadius.circular(AppDecorations.radiusMd),
                  ),
                  child: Icon(icon, size: 28, color: Colors.white),
                ),
                const SizedBox(height: 12),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  child: Text(
                    label,
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                      fontSize: 13,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
