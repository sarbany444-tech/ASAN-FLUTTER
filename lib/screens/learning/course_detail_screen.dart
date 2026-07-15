import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_decorations.dart';
import '../../models/learning_models.dart';
import '../../providers/auth_provider.dart';
import '../../providers/learning_provider.dart';

class CourseDetailScreen extends StatefulWidget {
  const CourseDetailScreen({super.key, required this.courseId});

  final String courseId;

  @override
  State<CourseDetailScreen> createState() => _CourseDetailScreenState();
}

class _CourseDetailScreenState extends State<CourseDetailScreen> {
  CourseModel? _course;
  List<LessonModel> _lessons = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final provider = context.read<LearningProvider>();
    final course = await provider.getCourse(widget.courseId);
    final lessons = await provider.getLessons(widget.courseId);
    if (!mounted) return;
    setState(() {
      _course = course;
      _lessons = lessons;
      _loading = false;
    });
  }

  Future<void> _enroll() async {
    final auth = context.read<AuthProvider>();
    final user = auth.user;
    if (user == null) return;
    await context.read<LearningProvider>().enroll(user.uid, widget.courseId);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Enrolled successfully!')),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final course = _course;
    if (course == null) {
      return Scaffold(
        appBar: AppBar(),
        body: const Center(child: Text('Course not found')),
      );
    }

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 200,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              title: Text(
                course.title,
                style: const TextStyle(fontSize: 16),
              ),
              background: Container(
                decoration: const BoxDecoration(
                  gradient: AppDecorations.greenGradient,
                ),
                child: const Center(
                  child: Icon(Icons.school_rounded,
                      size: 64, color: Colors.white54),
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(course.description,
                      style: Theme.of(context).textTheme.bodyLarge),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      const Icon(Icons.person_outline, size: 18),
                      const SizedBox(width: 6),
                      Text(course.teacherName),
                      const Spacer(),
                      const Icon(Icons.star, size: 18, color: AppColors.accentGold),
                      Text(' ${course.rating}'),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text('${course.lessonCount} lessons · ${course.studentCount} students'),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _enroll,
                      child: const Text('Enroll in Course'),
                    ),
                  ),
                ],
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
              child: Text(
                'Lessons',
                style: Theme.of(context).textTheme.titleLarge,
              ),
            ),
          ),
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                final lesson = _lessons[index];
                return ListTile(
                  leading: CircleAvatar(
                    backgroundColor:
                        AppColors.primaryGreen.withValues(alpha: 0.15),
                    child: Icon(
                      lesson.isVideo
                          ? Icons.play_arrow_rounded
                          : lesson.isPdf
                              ? Icons.picture_as_pdf_rounded
                              : Icons.quiz_outlined,
                      color: AppColors.primaryGreen,
                    ),
                  ),
                  title: Text(lesson.title),
                  subtitle: lesson.durationMinutes > 0
                      ? Text('${lesson.durationMinutes} min')
                      : Text(lesson.type.toUpperCase()),
                  trailing: lesson.isFree
                      ? const Chip(
                          label: Text('Free', style: TextStyle(fontSize: 11)),
                          visualDensity: VisualDensity.compact,
                        )
                      : const Icon(Icons.chevron_right),
                  onTap: () => context.push(
                    '/lesson/${lesson.id}',
                    extra: {'lesson': lesson, 'course': course},
                  ),
                );
              },
              childCount: _lessons.length,
            ),
          ),
        ],
      ),
    );
  }
}
