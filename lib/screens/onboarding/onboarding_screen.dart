import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_decorations.dart';
import '../../l10n/app_localizations.dart';
import '../../widgets/islamic_pattern_background.dart';
import '../../widgets/naseem_button.dart';
import '../../widgets/naseem_logo.dart';
import '../../widgets/premium_background.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final _pageController = PageController();
  int _currentPage = 0;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final pages = [
      _OnboardingPage(
        icon: Icons.mosque_rounded,
        accent: AppColors.primaryGreen,
        accent2: AppColors.cyan,
        title: l10n.onboardingTitle1,
        description: l10n.onboardingDesc1,
      ),
      _OnboardingPage(
        icon: Icons.menu_book_rounded,
        accent: AppColors.accentGold,
        accent2: AppColors.pink,
        title: l10n.onboardingTitle2,
        description: l10n.onboardingDesc2,
      ),
      _OnboardingPage(
        icon: Icons.verified_user_rounded,
        accent: AppColors.pink,
        accent2: AppColors.primaryGreen,
        title: l10n.onboardingTitle3,
        description: l10n.onboardingDesc3,
      ),
    ];

    return Scaffold(
      backgroundColor: AppColors.navy,
      body: IslamicPatternBackground(
        child: SafeArea(
          child: PremiumPage(
            maxWidth: 560,
            padding: EdgeInsets.zero,
            child: Column(
              children: [
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  child: Row(
                    children: [
                      const NaseemLogo(size: 44, showGlow: true, iconSize: 22),
                      const SizedBox(width: 10),
                      Text(
                        l10n.appTitle,
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              color: AppColors.textPrimary,
                              fontWeight: FontWeight.w800,
                            ),
                      ),
                      const Spacer(),
                      TextButton(
                        onPressed: () => context.go('/login'),
                        child: Text(
                          l10n.skip,
                          style: const TextStyle(color: AppColors.cyan),
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: PageView.builder(
                    controller: _pageController,
                    itemCount: pages.length,
                    onPageChanged: (i) => setState(() => _currentPage = i),
                    itemBuilder: (_, i) => pages[i],
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(pages.length, (i) {
                    final active = i == _currentPage;
                    return AnimatedContainer(
                      duration: const Duration(milliseconds: 280),
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      width: active ? 28 : 8,
                      height: 8,
                      decoration: BoxDecoration(
                        gradient: active ? AppDecorations.brandGradient : null,
                        color: active ? null : AppColors.border,
                        borderRadius: BorderRadius.circular(4),
                        boxShadow: active ? AppDecorations.goldGlow : null,
                      ),
                    );
                  }),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 20, 24, 28),
                  child: NaseemButton(
                    label: _currentPage < pages.length - 1
                        ? l10n.next
                        : l10n.getStarted,
                    icon: _currentPage < pages.length - 1
                        ? Icons.arrow_forward_rounded
                        : Icons.check_rounded,
                    onPressed: () {
                      if (_currentPage < pages.length - 1) {
                        _pageController.nextPage(
                          duration: const Duration(milliseconds: 350),
                          curve: Curves.easeOutCubic,
                        );
                      } else {
                        context.go('/login');
                      }
                    },
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

class _OnboardingPage extends StatelessWidget {
  const _OnboardingPage({
    required this.icon,
    required this.accent,
    required this.accent2,
    required this.title,
    required this.description,
  });

  final IconData icon;
  final Color accent;
  final Color accent2;
  final String title;
  final String description;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 16),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 168,
            height: 168,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  accent.withValues(alpha: 0.35),
                  accent2.withValues(alpha: 0.15),
                ],
              ),
              border: Border.all(color: Colors.white.withValues(alpha: 0.12)),
              boxShadow: [
                BoxShadow(
                  color: accent.withValues(alpha: 0.35),
                  blurRadius: 36,
                  offset: const Offset(0, 12),
                ),
              ],
            ),
            child: Icon(icon, size: 72, color: Colors.white),
          ),
          const SizedBox(height: 40),
          Text(
            title,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.displayMedium?.copyWith(
                  color: AppColors.textPrimary,
                ),
          ),
          const SizedBox(height: 16),
          Text(
            description,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: AppColors.textSecondary,
                  height: 1.55,
                ),
          ),
        ],
      ),
    );
  }
}
