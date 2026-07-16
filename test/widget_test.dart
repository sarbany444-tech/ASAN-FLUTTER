import 'package:flutter_test/flutter_test.dart';
import 'package:asan/core/constants/content_policy.dart';
import 'package:asan/services/moderation_service.dart';

void main() {
  test('Moderation rejects prohibited keywords', () {
    final service = ModerationService();
    expect(
      service.validateSync(
        title: 'Nightclub party',
        description: 'Fun times',
        category: 'lectures',
      ),
      isFalse,
    );
  });

  test('Moderation accepts Islamic content', () {
    final service = ModerationService();
    expect(
      service.validateSync(
        title: 'Surah Al-Fatiha Recitation',
        description: 'Beautiful Quran recitation',
        category: 'quran_recitation',
      ),
      isTrue,
    );
  });

  test('All allowed categories are defined', () {
    expect(ContentPolicy.allowedCategories.length, greaterThan(0));
    for (final cat in ContentPolicy.allowedCategories) {
      expect(ContentPolicy.categoryLabels.containsKey(cat), isTrue);
    }
  });
}
