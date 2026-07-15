/// Islamic content policy definitions for Naseem platform.
class ContentPolicy {
  ContentPolicy._();

  static const List<String> allowedCategories = [
    'quran_recitation',
    'quran_memorization',
    'tafsir',
    'hadith',
    'lectures',
    'reminders',
    'nasheed',
    'arabic_learning',
    'islamic_history',
    'children_education',
    'charity',
    'general_education',
  ];

  static const List<String> prohibitedKeywords = [
    'music video',
    'nightclub',
    'gambling',
    'casino',
    'alcohol',
    'beer',
    'wine',
    'drugs',
    'dating',
    'adult',
    'porn',
    'violence',
    'hate speech',
    'propaganda',
    'dance party',
    'strip club',
  ];

  static const List<String> allowedKeywords = [
    'quran',
    'surah',
    'ayah',
    'hadith',
    'sunnah',
    'prophet',
    'islam',
    'muslim',
    'prayer',
    'salah',
    'fasting',
    'ramadan',
    'hajj',
    'umrah',
    'tafsir',
    'nasheed',
    'dhikr',
    'dua',
    'scholar',
    'lecture',
    'reminder',
    'charity',
    'sadaqah',
    'zakat',
  ];

  static const Map<String, String> categoryLabels = {
    'quran_recitation': 'Quran Recitation',
    'quran_memorization': 'Quran Memorization',
    'tafsir': 'Tafsir & Explanation',
    'hadith': 'Hadith & Sunnah',
    'lectures': 'Islamic Lectures',
    'reminders': 'Islamic Reminders',
    'nasheed': 'Nasheed (Vocals)',
    'arabic_learning': 'Arabic Learning',
    'islamic_history': 'Islamic History',
    'children_education': 'Children Education',
    'charity': 'Charity & Community',
    'general_education': 'Islamic Education',
  };
}
