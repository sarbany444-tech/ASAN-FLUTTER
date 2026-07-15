import 'package:flutter/material.dart';
import '../../core/constants/subject_catalog.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_decorations.dart';

class LanguageLearningScreen extends StatelessWidget {
  const LanguageLearningScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Language Learning')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: AppDecorations.greenGradient,
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Learn a New Language',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  'Grammar, vocabulary, speaking, and more',
                  style: TextStyle(color: Colors.white70),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          ...SubjectCatalog.languages.map(
            (lang) => Card(
              margin: const EdgeInsets.only(bottom: 12),
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor:
                      AppColors.primaryGreen.withValues(alpha: 0.15),
                  child: Text(
                    lang.name[0],
                    style: const TextStyle(
                      color: AppColors.primaryGreen,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                title: Text(lang.name),
                subtitle: Text(lang.description),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => _showSkills(context, lang.name),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showSkills(BuildContext context, String language) {
    showModalBottomSheet(
      context: context,
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '$language Skills',
              style: Theme.of(ctx).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: SubjectCatalog.languageSkills
                  .map((skill) => Chip(label: Text(skill)))
                  .toList(),
            ),
            const SizedBox(height: 16),
            const Text(
              'Interactive exercises and daily words coming soon.',
              style: TextStyle(color: AppColors.textSecondary),
            ),
          ],
        ),
      ),
    );
  }
}
