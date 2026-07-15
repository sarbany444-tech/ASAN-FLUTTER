import 'package:flutter/material.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_decorations.dart';

class NaseemAppBar extends StatelessWidget implements PreferredSizeWidget {
  const NaseemAppBar({
    super.key,
    required this.title,
    this.actions,
    this.transparent = false,
    this.leading,
  });

  final String title;
  final List<Widget>? actions;
  final bool transparent;
  final Widget? leading;

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: transparent ? Colors.transparent : AppColors.navy.withValues(alpha: 0.92),
      elevation: 0,
      scrolledUnderElevation: 0,
      leading: leading,
      title: Text(
        title,
        style: const TextStyle(
          color: AppColors.textPrimary,
          fontWeight: FontWeight.w700,
          letterSpacing: -0.3,
        ),
      ),
      actions: actions,
      iconTheme: const IconThemeData(color: AppColors.textPrimary),
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(1),
        child: Container(
          height: 1,
          color: AppColors.border,
        ),
      ),
      shape: transparent
          ? null
          : const RoundedRectangleBorder(
              borderRadius: BorderRadius.vertical(
                bottom: Radius.circular(AppDecorations.radiusLg),
              ),
            ),
    );
  }
}
