import 'package:flutter/material.dart';

/// Grade 12 and platform subject catalog.
class SubjectCatalog {
  SubjectCatalog._();

  static const grade12Subjects = [
    SubjectItem('mathematics', 'Mathematics', 'Grade 12', Icons.calculate_outlined, 0xFF1565C0),
    SubjectItem('physics', 'Physics', 'Grade 12', Icons.science_outlined, 0xFF6A1B9A),
    SubjectItem('chemistry', 'Chemistry', 'Grade 12', Icons.biotech_outlined, 0xFF00838F),
    SubjectItem('biology', 'Biology', 'Grade 12', Icons.eco_outlined, 0xFF2E7D32),
    SubjectItem('english', 'English', 'Grade 12', Icons.language_outlined, 0xFFE65100),
    SubjectItem('arabic', 'Arabic', 'Grade 12', Icons.menu_book_outlined, 0xFF1B5E20),
    SubjectItem('kurdish', 'Kurdish', 'Grade 12', Icons.book_outlined, 0xFF4527A0),
    SubjectItem('history', 'History', 'Grade 12', Icons.history_edu_outlined, 0xFF5D4037),
    SubjectItem('geography', 'Geography', 'Grade 12', Icons.public_outlined, 0xFF0277BD),
    SubjectItem('islamic_education', 'Islamic Education', 'Grade 12', Icons.mosque_outlined, 0xFF1B5E20),
  ];

  static const languages = [
    LanguageItem('english', 'English', 'Beginner to Advanced'),
    LanguageItem('arabic', 'Arabic', 'Grammar & Conversation'),
    LanguageItem('kurdish', 'Kurdish', 'Kurdish for All Levels'),
    LanguageItem('turkish', 'Turkish', 'Practical Turkish'),
    LanguageItem('french', 'French', 'French for Beginners'),
  ];

  static const languageSkills = [
    'Grammar', 'Vocabulary', 'Speaking', 'Listening', 'Writing', 'Reading',
  ];
}

class SubjectItem {
  const SubjectItem(this.id, this.name, this.grade, this.icon, this.color);
  final String id;
  final String name;
  final String grade;
  final IconData icon;
  final int color;
}

class LanguageItem {
  const LanguageItem(this.id, this.name, this.description);
  final String id;
  final String name;
  final String description;
}
