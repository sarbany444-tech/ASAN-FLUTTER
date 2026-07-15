import 'package:flutter/material.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_decorations.dart';

class FeedTabBar extends StatelessWidget {
  const FeedTabBar({
    super.key,
    required this.selectedIndex,
    required this.onChanged,
  });

  final int selectedIndex;
  final ValueChanged<int> onChanged;

  static const tabs = ['Following', 'For You', 'Trending'];

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(tabs.length, (i) {
        final isSelected = i == selectedIndex;
        return GestureDetector(
          onTap: () => onChanged(i),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 220),
            margin: const EdgeInsets.symmetric(horizontal: 6),
            padding: EdgeInsets.symmetric(
              horizontal: isSelected ? 16 : 12,
              vertical: 8,
            ),
            decoration: isSelected
                ? AppDecorations.glassPill(active: true)
                : null,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  tabs[i],
                  style: TextStyle(
                    color: isSelected ? Colors.white : Colors.white60,
                    fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                    fontSize: isSelected ? 16 : 14,
                    letterSpacing: -0.2,
                    shadows: const [
                      Shadow(color: Colors.black54, blurRadius: 6),
                    ],
                  ),
                ),
                if (isSelected) ...[
                  const SizedBox(height: 4),
                  Container(
                    width: 20,
                    height: 3,
                    decoration: BoxDecoration(
                      gradient: AppDecorations.goldGradient,
                      borderRadius: BorderRadius.circular(2),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.accentGold.withValues(alpha: 0.5),
                          blurRadius: 6,
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
        );
      }),
    );
  }
}
