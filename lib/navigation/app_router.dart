import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../screens/splash_screen.dart';
import '../screens/onboarding_screen.dart';
import '../screens/login_screen.dart';
import '../screens/register_screen.dart';
import '../screens/main_shell.dart';
import '../screens/home_screen.dart';
import '../screens/community_screen.dart';
import '../screens/camera_screen.dart';
import '../screens/profile_screen.dart';
import '../screens/support_screen.dart';
import '../screens/result_screen.dart';
import '../screens/treatment_screen.dart';
import '../screens/hotlines_screen.dart';
import '../screens/roadmap_screen.dart';
import '../screens/forum_post_detail_screen.dart';
import '../screens/admin_review_screen.dart';
import '../screens/forgot_password_screen.dart';
import '../screens/history_screen.dart';
GoRouter createRouter(BuildContext context) {
  return GoRouter(
    initialLocation: '/splash',
    redirect: (context, state) {
      final authProvider = context.read<AuthProvider>();
      final isLoggedIn = authProvider.isLoggedIn;
      final isAuthRoute =
          state.matchedLocation == '/login' ||
          state.matchedLocation == '/register' ||
          state.matchedLocation == '/splash' ||
          state.matchedLocation == '/onboarding';

      if (isLoggedIn && isAuthRoute && state.matchedLocation != '/splash') {
        return '/home';
      }

      return null;
    },
    routes: [
      GoRoute(path: '/splash', builder: (_, _) => const SplashScreen()),
      GoRoute(path: '/onboarding', builder: (_, _) => const OnboardingScreen()),
      GoRoute(path: '/login', builder: (_, _) => const LoginScreen()),
      GoRoute(path: '/register', builder: (_, _) => const RegisterScreen()),
      GoRoute(
        path: '/forgot-password',
        builder: (context, state) => const ForgotPasswordScreen(),
      ),
      GoRoute(path: '/result', builder: (_, _) => const ResultScreen()),
      GoRoute(path: '/treatment', builder: (_, _) => const TreatmentScreen()),
      GoRoute(path: '/hotlines', builder: (_, _) => const HotlinesScreen()),
      GoRoute(
        path: '/roadmap',
        builder: (context, state) => const RoadmapScreen(),
      ),
      GoRoute(
        path: '/history',
        builder: (context, state) => const HistoryScreen(),
      ),
      ShellRoute(
        builder: (_, _, child) => MainShell(child: child),
        routes: [
          GoRoute(path: '/home', builder: (_, _) => const HomeScreen()),
          GoRoute(
            path: '/community',
            builder: (_, _) => const CommunityScreen(),
          ),
          GoRoute(
            path: '/community/post/:postId',
            builder: (context, state) => ForumPostDetailScreen(
              postId: state.pathParameters['postId'] ?? '',
            ),
          ),
          GoRoute(
            path: '/community/admin',
            builder: (context, state) => const AdminReviewScreen(),
          ),
          GoRoute(path: '/camera', builder: (_, _) => const CameraScreen()),
          GoRoute(path: '/profile', builder: (_, _) => const ProfileScreen()),
          GoRoute(path: '/support', builder: (_, _) => const SupportScreen()),
        ],
      ),
    ],
  );
}
