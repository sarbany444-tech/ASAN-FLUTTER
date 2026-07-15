import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_decorations.dart';
import '../../models/learning_models.dart';

class CourseCard extends StatelessWidget {
  const CourseCard({
    super.key,
    required this.course,
    this.onTap,
    this.compact = false,
  });

  final CourseModel course;
  final VoidCallback? onTap;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: compact ? 200 : double.infinity,
        decoration: AppDecorations.glass(opacity: 0.82),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: compact ? 100 : 120,
              decoration: const BoxDecoration(
                gradient: AppDecorations.brandGradient,
              ),
              child: Stack(
                children: [
                  Positioned(
                    top: -20,
                    right: -20,
                    child: Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white.withValues(alpha: 0.1),
                      ),
                    ),
                  ),
                  Center(
                    child: Icon(
                      Icons.school_rounded,
                      size: compact ? 36 : 48,
                      color: Colors.white.withValues(alpha: 0.95),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    course.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    course.teacherName,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColors.textSecondary,
                        ),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      const Icon(Icons.star_rounded,
                          size: 14, color: AppColors.accentGold),
                      const SizedBox(width: 4),
                      Text(
                        course.rating.toStringAsFixed(1),
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                      const Spacer(),
                      Icon(Icons.people_outline,
                          size: 14, color: AppColors.textSecondary),
                      const SizedBox(width: 4),
                      Text(
                        '${course.studentCount}',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
