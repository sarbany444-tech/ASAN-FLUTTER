import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart' hide ChangeNotifierProvider;
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';
import 'l10n/app_localizations.dart';
import 'providers/auth_provider.dart';
import 'providers/comment_provider.dart';
import 'providers/feed_provider.dart';
import 'providers/locale_provider.dart';
import 'providers/learning_provider.dart';
import 'providers/social_provider.dart';
import 'providers/theme_provider.dart';

class NaseemApp extends StatefulWidget {
  const NaseemApp({super.key});

  @override
  State<NaseemApp> createState() => _NaseemAppState();
}

class _NaseemAppState extends State<NaseemApp> {
  late final AuthProvider _authProvider;
  late final ThemeProvider _themeProvider;
  late final GoRouter _router;

  @override
  void initState() {
    super.initState();
    _authProvider = AuthProvider()..init();
    _themeProvider = ThemeProvider()..init();
    _router = AppRouter.router(_authProvider);
  }

  @override
  Widget build(BuildContext context) {
    return ProviderScope(
      child: MultiProvider(
        providers: [
          ChangeNotifierProvider.value(value: _authProvider),
          ChangeNotifierProvider.value(value: _themeProvider),
          ChangeNotifierProvider(create: (_) => LearningProvider()),
          ChangeNotifierProvider(create: (_) => FeedProvider()),
          ChangeNotifierProvider(create: (_) => SocialProvider()),
          ChangeNotifierProvider(create: (_) => CommentProvider()),
          ChangeNotifierProvider(create: (_) => LocaleProvider()),
        ],
        child: Consumer2<LocaleProvider, ThemeProvider>(
          builder: (context, localeProvider, themeProvider, _) {
            return MaterialApp.router(
              title: 'ASAN',
              debugShowCheckedModeBanner: false,
              theme: AppTheme.lightTheme,
              darkTheme: AppTheme.darkTheme,
              themeMode: themeProvider.themeMode,
              locale: localeProvider.locale,
              localizationsDelegates: AppLocalizations.localizationsDelegates,
              supportedLocales: AppLocalizations.supportedLocales,
              routerConfig: _router,
            );
          },
        ),
      ),
    );
  }
}
