import '../models/video_model.dart';
import '../models/social_models.dart';

/// Personalized For You recommendation engine.
/// Scores videos based on user preferences, engagement, and Islamic content quality.
class RecommendationService {
  List<VideoModel> rankForYou({
    required List<VideoModel> videos,
    required List<WatchHistoryEntry> watchHistory,
    required List<String> followingIds,
    required Map<String, int> categoryPreferences,
  }) {
    final watchedIds = watchHistory.map((e) => e.videoId).toSet();

    final scored = videos.map((video) {
      double score = video.engagementScore;

      // Engagement signals
      score += video.likeCount * 0.3;
      score += video.commentCount * 0.5;
      score += video.shareCount * 0.8;
      score += video.viewCount * 0.01;

      // Trending boost
      score += video.trendingScore * 2.0;

      // Verified scholar boost
      if (video.isUserVerified) score += 15;

      // Category preference from watch history
      final catPref = categoryPreferences[video.category] ?? 0;
      score += catPref * 3.0;

      // Following boost (still shown in For You but slightly lower than Following feed)
      if (followingIds.contains(video.userId)) score += 10;

      // Recency boost
      if (video.createdAt != null) {
        final hoursSince =
            DateTime.now().difference(video.createdAt!).inHours;
        if (hoursSince < 24) {
          score += 20;
        } else if (hoursSince < 72) {
          score += 10;
        }
      }

      // Penalize already watched
      if (watchedIds.contains(video.id)) score -= 50;

      return _ScoredVideo(video, score);
    }).toList();

    scored.sort((a, b) => b.score.compareTo(a.score));
    return scored.map((s) => s.video).toList();
  }

  List<VideoModel> rankTrending(List<VideoModel> videos) {
    final sorted = List<VideoModel>.from(videos);
    sorted.sort((a, b) {
      final scoreA = a.trendingScore + a.likeCount * 0.5 + a.viewCount * 0.01;
      final scoreB = b.trendingScore + b.likeCount * 0.5 + b.viewCount * 0.01;
      return scoreB.compareTo(scoreA);
    });
    return sorted;
  }

  Map<String, int> buildCategoryPreferences(List<WatchHistoryEntry> history) {
    final prefs = <String, int>{};
    for (final entry in history) {
      if (entry.category != null) {
        prefs[entry.category!] = (prefs[entry.category] ?? 0) + 1;
      }
    }
    return prefs;
  }

  List<String> extractHashtags(String text) {
    final regex = RegExp(r'#(\w+)');
    return regex
        .allMatches(text)
        .map((m) => m.group(1)!.toLowerCase())
        .take(10)
        .toList();
  }

  List<String> extractMentions(String text) {
    final regex = RegExp(r'@(\w+)');
    return regex.allMatches(text).map((m) => m.group(1)!).toList();
  }
}

class _ScoredVideo {
  _ScoredVideo(this.video, this.score);
  final VideoModel video;
  final double score;
}
