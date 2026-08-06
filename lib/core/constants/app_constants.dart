class AppConstants {
  AppConstants._();

  static const String appName = 'ASAN';
  static const String appTagline = 'Discover. Connect. Grow.';

  // Platform collections
  static const String usersCollection = 'users';
  static const String coursesCollection = 'courses';
  static const String lessonsCollection = 'lessons';
  static const String enrollmentsCollection = 'enrollments';
  static const String quizzesCollection = 'quizzes';
  static const String quizAttemptsCollection = 'quiz_attempts';
  static const String assignmentsCollection = 'assignments';
  static const String certificatesCollection = 'certificates';
  static const String liveClassesCollection = 'live_classes';
  static const String notificationsCollection = 'notifications';
  static const String communityPostsCollection = 'community_posts';
  static const String languageCoursesCollection = 'language_courses';
  static const String dailyContentCollection = 'daily_content';
  static const String reportsCollection = 'reports';
  static const String announcementsCollection = 'announcements';
  static const String medicalContentCollection = 'medical_content';
  static const String verificationRequestsCollection = 'verification_requests';

  // Social & video collections
  static const String videosCollection = 'videos';
  static const String commentsCollection = 'comments';
  static const String followsCollection = 'follows';
  static const String hashtagsCollection = 'hashtags';
  static const String conversationsCollection = 'conversations';
  static const String messagesCollection = 'messages';
  static const String liveStreamsCollection = 'live_streams';
  static const String donationsCollection = 'donations';
  static const String subscriptionsCollection = 'subscriptions';
  static const String savedVideosCollection = 'saved_videos';
  static const String watchHistoryCollection = 'watch_history';
  static const String moderationQueueCollection = 'moderation_queue';
  static const String strikesCollection = 'strikes';
  static const String draftsCollection = 'drafts';
  static const String creatorAnalyticsCollection = 'creator_analytics';

  // Marketplace monetization (Firebase-remote, no app update required)
  static const String configCollection = 'config';
  static const String monetizationConfigDoc = 'monetization';
  static const String analyticsCollection = 'analytics';
  static const String platformStatsDoc = 'platform_stats';
  static const String revenueEventsCollection = 'revenue_events';
  static const String businessInterestCollection = 'business_interest';
  static const String listingEventsCollection = 'listing_events';
  static const String listingsCollection = 'listings';

  // Storage paths
  static const String courseVideosPath = 'course_videos';
  static const String coursePdfsPath = 'course_pdfs';
  static const String avatarsPath = 'avatars';
  static const String certificatesPath = 'certificates';
  static const String videoStoragePath = 'videos';

  // Pagination
  static const int pageSize = 20;
  static const int feedPageSize = 10;
  static const int preloadVideoCount = 2;

  // Moderation
  static const int maxStrikesBeforeSuspension = 3;
  static const int maxStrikesBeforeBan = 5;
  static const int suspensionDays = 7;

  static const supportedLocales = ['en', 'ar', 'ku'];

  /// Production default: false. Enable locally with:
  /// `flutter run --dart-define=BYPASS_AUTH=true`
  static const bool bypassAuthForDevelopment =
      bool.fromEnvironment('BYPASS_AUTH', defaultValue: false);
}
