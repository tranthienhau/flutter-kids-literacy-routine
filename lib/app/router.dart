import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../features/activities/activity_complete_screen.dart';
import '../features/activities/activity_host.dart';
import '../features/library/library_screen.dart';
import '../features/library/story_detail_screen.dart';
import '../features/onboarding/child_setup_screen.dart';
import '../features/onboarding/welcome_screen.dart';
import '../features/profile/profile_screen.dart';
import '../features/progress/achievements_screen.dart';
import '../features/progress/progress_screen.dart';
import '../features/today/today_screen.dart';
import 'shell.dart';

final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/welcome',
    routes: [
      GoRoute(path: '/welcome', builder: (_, _) => const WelcomeScreen()),
      GoRoute(path: '/setup', builder: (_, _) => const ChildSetupScreen()),
      StatefulShellRoute.indexedStack(
        builder: (_, _, shell) => AppShell(shell: shell),
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(path: '/today', builder: (_, _) => const TodayScreen()),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/library',
                builder: (_, _) => const LibraryScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/progress',
                builder: (_, _) => const ProgressScreen(),
                routes: [
                  GoRoute(
                    path: 'achievements',
                    builder: (_, _) => const AchievementsScreen(),
                  ),
                ],
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/profile',
                builder: (_, _) => const ProfileScreen(),
              ),
            ],
          ),
        ],
      ),
      GoRoute(
        path: '/library/:id',
        builder: (_, s) => StoryDetailScreen(id: s.pathParameters['id']!),
      ),
      GoRoute(
        path: '/activity/:id',
        builder: (_, s) => ActivityHost(id: s.pathParameters['id']!),
      ),
      GoRoute(
        path: '/complete/:id',
        pageBuilder: (_, s) => CustomTransitionPage(
          child: ActivityCompleteScreen(id: s.pathParameters['id']!),
          transitionsBuilder: (_, a, _, c) =>
              FadeTransition(opacity: a, child: c),
        ),
      ),
    ],
  );
});
