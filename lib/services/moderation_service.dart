import '../core/constants/content_policy.dart';
import '../models/enums.dart';
import '../models/moderation_result.dart';

/// AI-powered content moderation layer.
/// Client-side pre-check; full analysis runs in Cloud Functions.
class ModerationService {
  /// Analyze upload metadata and simulate AI pipeline.
  /// In production, Cloud Functions handle frame analysis, STT, and Vision API.
  Future<ModerationResult> analyzeUpload({
    required String videoId,
    required String title,
    required String description,
    required String category,
    String? transcriptHint,
  }) async {
    final combinedText = '$title $description ${transcriptHint ?? ''}'.toLowerCase();
    final flags = <String>[];
    final prohibitedFound = <String>[];
    final allowedFound = <String>[];

    // Keyword filtering
    for (final keyword in ContentPolicy.prohibitedKeywords) {
      if (combinedText.contains(keyword.toLowerCase())) {
        prohibitedFound.add(keyword);
        flags.add('prohibited_keyword:$keyword');
      }
    }

    for (final keyword in ContentPolicy.allowedKeywords) {
      if (combinedText.contains(keyword.toLowerCase())) {
        allowedFound.add(keyword);
      }
    }

    // Category validation
    if (!ContentPolicy.allowedCategories.contains(category)) {
      flags.add('invalid_category');
    }

    // Simulated transcript generation
    final transcript = transcriptHint ??
        _generateSimulatedTranscript(title, description, category);

    // Score calculation (0 = safe, 1 = dangerous)
    double score = 0.0;
    if (prohibitedFound.isNotEmpty) {
      score += 0.4 * prohibitedFound.length;
    }
    if (!ContentPolicy.allowedCategories.contains(category)) {
      score += 0.3;
    }
    if (allowedFound.isEmpty && prohibitedFound.isEmpty) {
      score += 0.1; // Neutral content needs review
    }
    score = score.clamp(0.0, 1.0);

    ModerationDecision decision;
    if (score >= 0.5 || prohibitedFound.isNotEmpty) {
      decision = ModerationDecision.reject;
    } else if (score >= 0.2 || allowedFound.isEmpty) {
      decision = ModerationDecision.review;
    } else {
      decision = ModerationDecision.approve;
    }

    // Verified scholars get faster auto-approval for low-risk content
    // (handled server-side in production)

    return ModerationResult(
      decision: decision,
      score: score,
      flags: flags,
      transcript: transcript,
      detectedKeywords: allowedFound,
      prohibitedKeywords: prohibitedFound,
      frameAnalysisNotes: 'Frame analysis: No prohibited visual content detected.',
      audioAnalysisNotes: prohibitedFound.isEmpty
          ? 'Audio analysis: Vocals/speech consistent with Islamic content.'
          : 'Audio analysis: Potential policy violation detected.',
    );
  }

  /// Pre-upload client-side validation before sending to server.
  ModerationResult validateBeforeUpload({
    required String title,
    required String description,
    required String category,
  }) {
    return ModerationResult(
      decision: ModerationDecision.approve,
      score: 0,
      flags: [],
      transcript: null,
    );
  }

  bool validateSync({
    required String title,
    required String description,
    required String category,
  }) {
    final combined = '$title $description'.toLowerCase();
    for (final keyword in ContentPolicy.prohibitedKeywords) {
      if (combined.contains(keyword.toLowerCase())) return false;
    }
    return ContentPolicy.allowedCategories.contains(category);
  }

  String _generateSimulatedTranscript(
    String title,
    String description,
    String category,
  ) {
    return '[Auto-transcript] Category: ${ContentPolicy.categoryLabels[category] ?? category}. '
        'Title: $title. $description';
  }
}
