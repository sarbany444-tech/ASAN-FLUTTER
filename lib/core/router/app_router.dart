import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../providers/auth_provider.dart';
import '../../screens/auth/login_screen.dart';
import '../../screens/auth/register_screen.dart';
import '../../screens/home/main_shell.dart';
import '../../screens/onboarding/onboarding_screen.dart';
import '../../screens/splash_screen.dart';
import '../../screens/islamic/prayer_times_screen.dart';
import '../../screens/islamic/qibla_screen.dart';
import '../../screens/islamic/islamic_calendar_screen.dart';
import '../../screens/islamic/daily_content_screen.dart';
import '../../screens/islamic/category_section_screen.dart';
import '../../screens/admin/admin_dashboard_screen.dart';
import '../../screens/admin/moderator_dashboard_screen.dart';
import '../../screens/profile/settings_screen.dart';
import '../../screens/profile/edit_profile_screen.dart';
import '../../screens/profile/community_guidelines_screen.dart';
import '../../screens/video/report_screen.dart';
import '../../screens/search/search_screen.dart';
import '../../screens/profile/user_profile_screen.dart';
import '../../screens/profile/library_screen.dart';
import '../../screens/creator/creator_dashboard_screen.dart';
import '../../screens/social/notifications_screen.dart';
import '../../screens/social/messages_screen.dart';
import '../../screens/social/live_streams_screen.dart';
import '../../screens/discovery/hashtag_screen.dart';
import '../../screens/learning/course_detail_screen.dart';
import '../../screens/learning/courses_screen.dart';
import '../../screens/learning/language_learning_screen.dart';
import '../../screens/learning/lesson_player_screen.dart';
import '../../screens/learning/quiz_screen.dart';
import '../../screens/learning/student_dashboard_screen.dart';
import '../../screens/learning/teacher_dashboard_screen.dart';
import '../../screens/learning/live_classes_screen.dart';
import '../../screens/learning/community_screen.dart';
import '../../screens/upload/video_editor_screen.dart';
import '../../features/creator/presentation/creator_verification_screen.dart';
import '../../features/medical/presentation/medical_hub_screen.dart';
import '../../features/medical/presentation/medical_category_screen.dart';
import '../../screens/islamic/islamic_hub_screen.dart';
import '../../screens/explore/explore_screen.dart';
import '../../models/learning_models.dart';
import '../constants/app_constants.dart';

class AppRouter {
  static final _rootNavigatorKey = GlobalKey<NavigatorState>();
  static final _shellNavigatorKey = GlobalKey<NavigatorState>();

  static GoRouter router(AuthProvider authProvider) {
    return GoRouter(
      navigatorKey: _rootNavigatorKey,
      initialLocation: AppConstants.bypassAuthForDevelopment ? '/home' : '/splash',
      refreshListenable: authProvider,
      redirect: (context, state) {
        if (AppConstants.bypassAuthForDevelopment) {
          return null;
        }

        final isLoggedIn = authProvider.isAuthenticated;
        final path = state.matchedLocation;
        final isAuthRoute = path == '/login' || path == '/register';
        final isPublicRoute = path == '/splash' || path == '/onboarding';

        if (path == '/splash') return null;
        if (!isLoggedIn && !isAuthRoute && !isPublicRoute) return '/login';
        if (isLoggedIn && isAuthRoute) return '/home';
        if (isLoggedIn && path == '/onboarding') return '/home';
        return null;
      },
      routes: [
        GoRoute(
          path: '/splash',
          builder: (_, _) => const SplashScreen(),
        ),
        GoRoute(
          path: '/onboarding',
          builder: (_, _) => const OnboardingScreen(),
        ),
        GoRoute(
          path: '/login',
          builder: (_, _) => const LoginScreen(),
        ),
        GoRoute(
          path: '/register',
          builder: (_, _) => const RegisterScreen(),
        ),
        ShellRoute(
          navigatorKey: _shellNavigatorKey,
          builder: (_, _, child) => MainShell(child: child),
          routes: [
            GoRoute(
              path: '/home',
              pageBuilder: (_, _) => const NoTransitionPage(
                child: SizedBox.shrink(),
              ),
            ),
            GoRoute(
              path: '/learn-tab',
              pageBuilder: (_, _) => const NoTransitionPage(
                child: SizedBox.shrink(),
              ),
            ),
            GoRoute(
              path: '/upload-tab',
              pageBuilder: (_, _) => const NoTransitionPage(
                child: SizedBox.shrink(),
              ),
            ),
            GoRoute(
              path: '/discover-tab',
              pageBuilder: (_, _) => const NoTransitionPage(
                child: SizedBox.shrink(),
              ),
            ),
            GoRoute(
              path: '/profile',
              pageBuilder: (_, _) => const NoTransitionPage(
                child: SizedBox.shrink(),
              ),
            ),
          ],
        ),
        GoRoute(
          path: '/prayer-times',
          builder: (_, _) => const PrayerTimesScreen(),
        ),
        GoRoute(
          path: '/qibla',
          builder: (_, _) => const QiblaScreen(),
        ),
        GoRoute(
          path: '/islamic-calendar',
          builder: (_, _) => const IslamicCalendarScreen(),
        ),
        GoRoute(
          path: '/daily-quran',
          builder: (_, _) => const DailyContentScreen(type: 'quran'),
        ),
        GoRoute(
          path: '/daily-hadith',
          builder: (_, _) => const DailyContentScreen(type: 'hadith'),
        ),
        GoRoute(
          path: '/daily-reminder',
          builder: (_, _) => const DailyContentScreen(type: 'reminder'),
        ),
        GoRoute(
          path: '/section/:category',
          builder: (_, state) => CategorySectionScreen(
            category: state.pathParameters['category']!,
          ),
        ),
        GoRoute(
          path: '/admin',
          builder: (_, _) => const AdminDashboardScreen(),
        ),
        GoRoute(
          path: '/moderator',
          builder: (_, _) => const ModeratorDashboardScreen(),
        ),
        GoRoute(
          path: '/settings',
          builder: (_, _) => const SettingsScreen(),
        ),
        GoRoute(
          path: '/edit-profile',
          builder: (_, _) => const EditProfileScreen(),
        ),
        GoRoute(
          path: '/guidelines',
          builder: (_, _) => const CommunityGuidelinesScreen(),
        ),
        GoRoute(
          path: '/report/:videoId',
          builder: (_, state) => ReportScreen(
            videoId: state.pathParameters['videoId']!,
          ),
        ),
        GoRoute(
          path: '/search',
          builder: (_, _) => const SearchScreen(),
        ),
        GoRoute(
          path: '/user/:userId',
          builder: (_, state) => UserProfileScreen(
            userId: state.pathParameters['userId']!,
          ),
        ),
        GoRoute(
          path: '/hashtag/:tag',
          builder: (_, state) => HashtagScreen(
            tag: state.pathParameters['tag']!,
          ),
        ),
        GoRoute(
          path: '/notifications',
          builder: (_, _) => const NotificationsScreen(),
        ),
        GoRoute(
          path: '/messages',
          builder: (_, _) => const MessagesScreen(),
        ),
        GoRoute(
          path: '/chat/:conversationId',
          builder: (_, state) => ChatScreen(
            conversationId: state.pathParameters['conversationId']!,
          ),
        ),
        GoRoute(
          path: '/live',
          builder: (_, _) => const LiveStreamsScreen(),
        ),
        GoRoute(
          path: '/creator-dashboard',
          builder: (_, _) => const CreatorDashboardScreen(),
        ),
        GoRoute(
          path: '/saved',
          builder: (_, _) => const SavedVideosScreen(),
        ),
        GoRoute(
          path: '/history',
          builder: (_, _) => const WatchHistoryScreen(),
        ),
        GoRoute(
          path: '/courses',
          builder: (_, state) => CoursesScreen(
            initialSubject: state.uri.queryParameters['subject'],
          ),
        ),
        GoRoute(
          path: '/course/:courseId',
          builder: (_, state) => CourseDetailScreen(
            courseId: state.pathParameters['courseId']!,
          ),
        ),
        GoRoute(
          path: '/lesson/:lessonId',
          builder: (_, state) {
            final extra = state.extra as Map<String, dynamic>?;
            return LessonPlayerScreen(
              lesson: extra?['lesson'] as LessonModel? ??
                  LessonModel(
                    id: state.pathParameters['lessonId']!,
                    courseId: '',
                    title: 'Lesson',
                    type: 'video',
                  ),
              course: extra?['course'] as CourseModel?,
            );
          },
        ),
        GoRoute(
          path: '/languages',
          builder: (_, _) => const LanguageLearningScreen(),
        ),
        GoRoute(
          path: '/teacher-dashboard',
          builder: (_, _) => const TeacherDashboardScreen(),
        ),
        GoRoute(
          path: '/student-dashboard',
          builder: (_, _) => const StudentDashboardScreen(),
        ),
        GoRoute(
          path: '/explore',
          builder: (_, _) => const ExploreScreen(),
        ),
        GoRoute(
          path: '/islamic-hub',
          builder: (_, _) => const IslamicHubScreen(),
        ),
        GoRoute(
          path: '/medical',
          builder: (_, _) => const MedicalHubScreen(),
        ),
        GoRoute(
          path: '/medical/:categoryId',
          builder: (_, state) => MedicalCategoryScreen(
            categoryId: state.pathParameters['categoryId']!,
          ),
        ),
        GoRoute(
          path: '/creator-verification',
          builder: (_, _) => const CreatorVerificationScreen(),
        ),
        GoRoute(
          path: '/live-classes',
          builder: (_, _) => const LiveClassesScreen(),
        ),
        GoRoute(
          path: '/community',
          builder: (_, _) => const CommunityScreen(),
        ),
        GoRoute(
          path: '/quiz',
          builder: (_, state) => QuizScreen(
            quiz: state.extra as QuizModel?,
          ),
        ),
        GoRoute(
          path: '/video-editor',
          builder: (_, state) => VideoEditorScreen(
            videoName: state.extra as String? ?? 'video.mp4',
          ),
        ),
      ],
    );
  }
}
