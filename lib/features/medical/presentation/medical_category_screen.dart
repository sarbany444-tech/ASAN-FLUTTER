import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../data/medical_catalog.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_decorations.dart';
import '../../../widgets/naseem_app_bar.dart';
import '../../../widgets/naseem_button.dart';
import '../../../widgets/premium_background.dart';

class MedicalCategoryScreen extends StatelessWidget {
  const MedicalCategoryScreen({super.key, required this.categoryId});

  final String categoryId;

  @override
  Widget build(BuildContext context) {
    final category = MedicalCatalog.categories.firstWhere(
      (c) => c.id == categoryId,
      orElse: () => MedicalCatalog.categories.first,
    );
    final color = Color(category.color);

    return Scaffold(
      backgroundColor: AppColors.navy,
      appBar: NaseemAppBar(title: category.title),
      body: PremiumBackground(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
          children: [
            Container(
              decoration: AppDecorations.glass(opacity: 0.7),
              child: ListTile(
                contentPadding: const EdgeInsets.all(16),
                leading: Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.15),
                    borderRadius:
                        BorderRadius.circular(AppDecorations.radiusLg),
                  ),
                  child: Icon(category.icon, color: color, size: 28),
                ),
                title: Text(
                  category.title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
                subtitle: Padding(
                  padding: const EdgeInsets.only(top: 6),
                  child: Text(category.description),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.warning.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(AppDecorations.radiusLg),
                border: Border.all(
                  color: AppColors.warning.withValues(alpha: 0.35),
                ),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.info_outline_rounded,
                      color: AppColors.warning, size: 20),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      MedicalCatalog.disclaimer,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 28),
            Text(
              'Featured Content',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 12),
            ...List.generate(
              3,
              (i) => Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () {},
                    borderRadius:
                        BorderRadius.circular(AppDecorations.radiusXl),
                    child: Ink(
                      decoration: AppDecorations.glass(opacity: 0.65),
                      child: ListTile(
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 4,
                        ),
                        leading: Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            gradient: AppDecorations.cyanPurpleGradient,
                            borderRadius: BorderRadius.circular(
                              AppDecorations.radiusMd,
                            ),
                          ),
                          child: const Icon(
                            Icons.play_circle_outline_rounded,
                            color: Colors.white,
                          ),
                        ),
                        title: Text(
                          '${category.title} Lesson ${i + 1}',
                          style: const TextStyle(fontWeight: FontWeight.w600),
                        ),
                        subtitle: const Text('Verified healthcare creator'),
                        trailing: const Icon(
                          Icons.chevron_right_rounded,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
            NaseemButton(
              label: 'Join Live Medical Session',
              icon: Icons.live_tv_rounded,
              onPressed: () => context.push('/live'),
            ),
          ],
        ),
      ),
    );
  }
}
