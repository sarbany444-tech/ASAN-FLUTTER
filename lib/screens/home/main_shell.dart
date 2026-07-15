import 'dart:ui';
import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_decorations.dart';
import '../home/feed_screen.dart';
import '../upload/upload_screen.dart';
import '../profile/profile_screen.dart';
import '../../features/learning/presentation/learn_hub_screen.dart';
import '../../features/discover/presentation/discover_hub_screen.dart';

/// Unified platform shell: TikTok feed + learning + upload + discover + profile.
class MainShell extends StatefulWidget {
  const MainShell({super.key, required this.child});

  final Widget child;

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _currentIndex = 0;

  late final List<Widget> _screens = [
    const FeedScreen(),
    const LearnHubScreen(),
    UploadScreen(onPosted: () => setState(() => _currentIndex = 0)),
    const DiscoverHubScreen(),
    const ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final isDarkTab = _currentIndex == 0 || _currentIndex == 2;

    return Scaffold(
      extendBody: true,
      backgroundColor:
          isDarkTab ? Colors.black : AppColors.navy,
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(AppDecorations.radiusXl),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
            child: Container(
              decoration: BoxDecoration(
                color: AppColors.navyCard.withValues(alpha: 0.72),
                borderRadius:
                    BorderRadius.circular(AppDecorations.radiusXl),
                border: Border.all(color: AppColors.border),
                boxShadow: AppDecorations.softShadow,
              ),
              child: SafeArea(
                top: false,
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _NavItem(
                        icon: Icons.home_outlined,
                        activeIcon: Icons.home_rounded,
                        label: 'Feed',
                        isActive: _currentIndex == 0,
                        onTap: () => setState(() => _currentIndex = 0),
                      ),
                      _NavItem(
                        icon: Icons.school_outlined,
                        activeIcon: Icons.school_rounded,
                        label: 'Learn',
                        isActive: _currentIndex == 1,
                        onTap: () => setState(() => _currentIndex = 1),
                      ),
                      _UploadNavButton(
                        isActive: _currentIndex == 2,
                        onTap: () => setState(() => _currentIndex = 2),
                      ),
                      _NavItem(
                        icon: Icons.explore_outlined,
                        activeIcon: Icons.explore_rounded,
                        label: 'Discover',
                        isActive: _currentIndex == 3,
                        onTap: () => setState(() => _currentIndex = 3),
                      ),
                      _NavItem(
                        icon: Icons.person_outline_rounded,
                        activeIcon: Icons.person_rounded,
                        label: 'Profile',
                        isActive: _currentIndex == 4,
                        onTap: () => setState(() => _currentIndex = 4),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  const _NavItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
    required this.isActive,
    required this.onTap,
  });

  final IconData icon;
  final IconData activeIcon;
  final String label;
  final bool isActive;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 56,
        padding: const EdgeInsets.symmetric(vertical: 4),
        decoration: isActive
            ? BoxDecoration(
                color: AppColors.primaryGreen.withValues(alpha: 0.12),
                borderRadius:
                    BorderRadius.circular(AppDecorations.radiusMd),
              )
            : null,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isActive ? activeIcon : icon,
              color: isActive
                  ? AppColors.primaryGreen
                  : AppColors.textSecondary,
              size: 24,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 10,
                fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
                color: isActive
                    ? AppColors.primaryGreen
                    : AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _UploadNavButton extends StatelessWidget {
  const _UploadNavButton({
    required this.isActive,
    required this.onTap,
  });

  final bool isActive;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 52,
        height: 52,
        margin: const EdgeInsets.only(bottom: 4),
        decoration: BoxDecoration(
          gradient: AppDecorations.brandGradient,
          borderRadius: BorderRadius.circular(AppDecorations.radiusLg),
          boxShadow: [
            BoxShadow(
              color: AppColors.primaryGreen.withValues(alpha: isActive ? 0.5 : 0.3),
              blurRadius: isActive ? 20 : 12,
              offset: const Offset(0, 4),
            ),
          ],
          border: Border.all(
            color: isActive
                ? AppColors.white.withValues(alpha: 0.6)
                : Colors.transparent,
            width: 2,
          ),
        ),
        child: const Icon(
          Icons.add_rounded,
          color: AppColors.white,
          size: 28,
        ),
      ),
    );
  }
}
