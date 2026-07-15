import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../models/learning_models.dart';

class LessonPlayerScreen extends StatelessWidget {
  const LessonPlayerScreen({
    super.key,
    required this.lesson,
    this.course,
  });

  final LessonModel lesson;
  final CourseModel? course;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(lesson.title)),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          AspectRatio(
            aspectRatio: 16 / 9,
            child: Container(
              color: Colors.black,
              child: lesson.isVideo
                  ? const Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.play_circle_fill_rounded,
                              size: 72, color: Colors.white54),
                          SizedBox(height: 12),
                          Text(
                            'Video player ready',
                            style: TextStyle(color: Colors.white54),
                          ),
                          Text(
                            'Connect Firebase Storage for playback',
                            style:
                                TextStyle(color: Colors.white38, fontSize: 12),
                          ),
                        ],
                      ),
                    )
                  : lesson.isPdf
                      ? const Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.picture_as_pdf_rounded,
                                  size: 72, color: Colors.white54),
                              SizedBox(height: 12),
                              Text(
                                'PDF viewer ready',
                                style: TextStyle(color: Colors.white54),
                              ),
                            ],
                          ),
                        )
                      : const Center(
                          child: Icon(Icons.quiz_outlined,
                              size: 72, color: Colors.white54),
                        ),
            ),
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                if (course != null) ...[
                  Text(
                    course!.title,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  const SizedBox(height: 4),
                ],
                Text(
                  lesson.title,
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                if (lesson.description != null) ...[
                  const SizedBox(height: 12),
                  Text(lesson.description!),
                ],
                const SizedBox(height: 24),
                if (lesson.isVideo)
                  ElevatedButton.icon(
                    onPressed: () {},
                    icon: const Icon(Icons.play_arrow_rounded),
                    label: const Text('Play Lesson'),
                  ),
                if (lesson.isPdf)
                  OutlinedButton.icon(
                    onPressed: () {},
                    icon: const Icon(Icons.download_rounded),
                    label: const Text('Download for Offline'),
                  ),
                const SizedBox(height: 12),
                OutlinedButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.bookmark_outline),
                  label: const Text('Save Lesson'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.primaryGreen,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
