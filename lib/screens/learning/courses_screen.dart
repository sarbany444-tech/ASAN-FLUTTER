import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../core/constants/subject_catalog.dart';
import '../../core/theme/app_colors.dart';
import '../../providers/learning_provider.dart';
import '../../widgets/course_card.dart';

class CoursesScreen extends StatefulWidget {
  const CoursesScreen({super.key, this.initialSubject});

  final String? initialSubject;

  @override
  State<CoursesScreen> createState() => _CoursesScreenState();
}

class _CoursesScreenState extends State<CoursesScreen> {
  String? _selectedSubject;

  @override
  void initState() {
    super.initState();
    _selectedSubject = widget.initialSubject;
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadCourses());
  }

  void _loadCourses() {
    final provider = context.read<LearningProvider>();
    if (_selectedSubject != null) {
      provider.loadCoursesBySubject(_selectedSubject!);
    } else {
      provider.loadHomeData();
    }
  }

  @override
  Widget build(BuildContext context) {
    final learning = context.watch<LearningProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Courses'),
        actions: [
          IconButton(
            icon: const Icon(Icons.language_rounded),
            tooltip: 'Language Learning',
            onPressed: () => context.push('/languages'),
          ),
        ],
      ),
      body: Column(
        children: [
          SizedBox(
            height: 48,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              children: [
                _FilterChip(
                  label: 'All',
                  selected: _selectedSubject == null,
                  onTap: () {
                    setState(() => _selectedSubject = null);
                    context.read<LearningProvider>().loadHomeData();
                  },
                ),
                ...SubjectCatalog.grade12Subjects.map(
                  (s) => _FilterChip(
                    label: s.name,
                    selected: _selectedSubject == s.id,
                    onTap: () {
                      setState(() => _selectedSubject = s.id);
                      context
                          .read<LearningProvider>()
                          .loadCoursesBySubject(s.id);
                    },
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: learning.isLoading
                ? const Center(child: CircularProgressIndicator())
                : learning.courses.isEmpty
                    ? const Center(child: Text('No courses found'))
                    : ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: learning.courses.length,
                        itemBuilder: (_, i) {
                          final course = learning.courses[i];
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 16),
                            child: CourseCard(
                              course: course,
                              onTap: () =>
                                  context.push('/course/${course.id}'),
                            ),
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  const _FilterChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
      child: FilterChip(
        label: Text(label),
        selected: selected,
        onSelected: (_) => onTap(),
        selectedColor: AppColors.primaryGreen.withValues(alpha: 0.2),
        checkmarkColor: AppColors.primaryGreen,
      ),
    );
  }
}
