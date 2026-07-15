import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/app_constants.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_decorations.dart';
import '../../widgets/naseem_logo.dart';
import '../../widgets/premium_background.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<double> _glowAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    );
    _fadeAnimation = CurvedAnimation(parent: _controller, curve: Curves.easeOut);
    _scaleAnimation = Tween<double>(begin: 0.82, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutBack),
    );
    _glowAnimation = Tween<double>(begin: 0.4, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
    _controller.forward();
    _navigate();
  }

  Future<void> _navigate() async {
    await Future.delayed(const Duration(seconds: 2));
    if (!mounted) return;
    context.go(
      AppConstants.bypassAuthForDevelopment ? '/home' : '/onboarding',
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.navy,
      body: PremiumBackground(
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: ScaleTransition(
            scale: _scaleAnimation,
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  AnimatedBuilder(
                    animation: _glowAnimation,
                    builder: (context, child) {
                      return Container(
                        padding: const EdgeInsets.all(18),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.primaryGreen
                                  .withValues(alpha: 0.35 * _glowAnimation.value),
                              blurRadius: 40,
                              spreadRadius: 8,
                            ),
                            BoxShadow(
                              color: AppColors.pink
                                  .withValues(alpha: 0.2 * _glowAnimation.value),
                              blurRadius: 60,
                              spreadRadius: 2,
                            ),
                          ],
                        ),
                        child: child,
                      );
                    },
                    child: const NaseemLogo(size: 130),
                  ),
                  const SizedBox(height: 32),
                  const NaseemWordmark(light: true),
                  const SizedBox(height: 12),
                  Text(
                    'Learn · Create · Connect',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppColors.textSecondary,
                          letterSpacing: 1.2,
                        ),
                  ),
                  const SizedBox(height: 56),
                  Container(
                    width: 44,
                    height: 44,
                    padding: const EdgeInsets.all(10),
                    decoration: AppDecorations.glass(opacity: 0.55),
                    child: CircularProgressIndicator(
                      strokeWidth: 2.5,
                      color: AppColors.accentGold.withValues(alpha: 0.95),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
