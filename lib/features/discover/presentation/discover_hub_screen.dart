import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_decorations.dart';
import '../../../widgets/naseem_button.dart';
import '../../../widgets/premium_background.dart';

/// Unified discovery hub for trending, Islamic, medical, and language content.
class DiscoverHubScreen extends StatelessWidget {
  const DiscoverHubScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final platforms = [
      _PlatformCard(
        title: 'Trending',
        subtitle: 'Popular videos and hashtags',
        icon: Icons.trending_up_rounded,
        gradient: AppDecorations.goldGradient,
        route: '/explore',
      ),
      _PlatformCard(
        title: 'Islamic',
        subtitle: 'Quran, Hadith, prayer times, lectures',
        icon: Icons.mosque_rounded,
        gradient: AppDecorations.purplePinkGradient,
        route: '/islamic-hub',
      ),
      _PlatformCard(
        title: 'Medical',
        subtitle: 'Health education from verified doctors',
        icon: Icons.medical_services_rounded,
        gradient: AppDecorations.cyanPurpleGradient,
        route: '/medical',
      ),
      _PlatformCard(
        title: 'Languages',
        subtitle: 'English, Arabic, Kurdish, Turkish',
        icon: Icons.translate_rounded,
        gradient: const LinearGradient(
          colors: [AppColors.accentGold, AppColors.pink],
        ),
        route: '/languages',
      ),
      _PlatformCard(
        title: 'Live',
        subtitle: 'Live streams and live classes',
        icon: Icons.sensors_rounded,
        gradient: const LinearGradient(
          colors: [AppColors.pink, Color(0xFFC62828)],
        ),
        route: '/live',
      ),
      _PlatformCard(
        title: 'Search',
        subtitle: 'Teachers, courses, videos, subjects',
        icon: Icons.search_rounded,
        gradient: const LinearGradient(
          colors: [AppColors.primaryGreen, AppColors.cyan],
        ),
        route: '/search',
      ),
    ];

    return Scaffold(
      backgroundColor: AppColors.navy,
      body: PremiumBackground(
        child: CustomScrollView(
          slivers: [
            SliverAppBar(
              expandedHeight: 130,
              pinned: true,
              backgroundColor: AppColors.navy.withValues(alpha: 0.85),
              title: const Text(
                'Discover',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              flexibleSpace: FlexibleSpaceBar(
                background: Container(
                  decoration: const BoxDecoration(
                    gradient: AppDecorations.heroGradient,
                  ),
                  child: Align(
                    alignment: Alignment.bottomRight,
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Icon(
                        Icons.explore_rounded,
                        size: 80,
                        color: AppColors.cyan.withValues(alpha: 0.15),
                      ),
                    ),
                  ),
                ),
              ),
              actions: [
                IconButton(
                  icon: const Icon(Icons.search_rounded),
                  onPressed: () => context.push('/search'),
                ),
              ],
            ),
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
              sliver: SliverGrid(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 12,
                  childAspectRatio: 1.05,
                ),
                delegate: SliverChildBuilderDelegate(
                  (context, index) => _PlatformTile(card: platforms[index]),
                  childCount: platforms.length,
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 24, 20, 100),
                child: NaseemButton(
                  label: 'Browse Trending Videos',
                  icon: Icons.trending_up_rounded,
                  onPressed: () => context.push('/explore'),
                  expand: true,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PlatformCard {
  const _PlatformCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.gradient,
    required this.route,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final Gradient gradient;
  final String route;
}

class _PlatformTile extends StatelessWidget {
  const _PlatformTile({required this.card});
  final _PlatformCard card;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(AppDecorations.radiusXl),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => context.push(card.route),
        child: Ink(
          decoration: BoxDecoration(
            gradient: card.gradient,
            borderRadius: BorderRadius.circular(AppDecorations.radiusXl),
            boxShadow: AppDecorations.softShadow,
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius:
                        BorderRadius.circular(AppDecorations.radiusMd),
                  ),
                  child: Icon(card.icon, color: Colors.white, size: 24),
                ),
                const Spacer(),
                Text(
                  card.title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  card.subtitle,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.85),
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
