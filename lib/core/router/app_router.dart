import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../features/auth/data/auth_repository.dart';
import '../../features/auth/presentation/login_screen.dart';
import '../../features/splash/presentation/splash_screen.dart';
import '../../features/welcome/presentation/welcome_screen.dart';
import '../../features/welcome/presentation/welcome_grid_screen.dart';
import '../../features/wallpapers/presentation/feed_screen.dart';
import '../../features/wallpapers/presentation/generate_screen.dart';
import '../../features/profile/presentation/profile_screen.dart';
import '../../features/admin/presentation/admin_dashboard_screen.dart';
import 'scaffold_with_nav_bar.dart';

part 'app_router.g.dart';

final _rootNavigatorKey = GlobalKey<NavigatorState>();

@riverpod
GoRouter goRouter(Ref ref) {
  final authState = ref.watch(authStateProvider);

  return GoRouter(
    initialLocation: '/splash',
    navigatorKey: _rootNavigatorKey,
    debugLogDiagnostics: true,
    redirect: (context, state) {
      final isLoggedIn = authState.asData?.value != null;
      final currentPath = state.uri.path;
      final isSplashOrWelcome = currentPath == '/splash' || 
                                 currentPath == '/welcome' || 
                                 currentPath == '/welcome-grid';
      final isLoggingIn = currentPath == '/login';

      // Allow splash and welcome screens without auth check
      if (isSplashOrWelcome) return null;

      if (authState.isLoading || authState.hasError) return null;

      if (!isLoggedIn && !isLoggingIn) {
        return '/login';
      }

      if (isLoggedIn && isLoggingIn) {
        return '/feed';
      }

      return null;
    },
    // Using stream listenable to trigger redirects
    refreshListenable: AuthStateListenable(authState), 
    routes: [
      GoRoute(
        path: '/splash',
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: '/welcome',
        builder: (context, state) => const WelcomeScreen(),
      ),
      GoRoute(
        path: '/welcome-grid',
        builder: (context, state) => const WelcomeGridScreen(),
      ),
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/admin',
        builder: (context, state) => const AdminDashboardScreen(),
      ),
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return ScaffoldWithNavBar(navigationShell: navigationShell);
        },
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/feed',
                builder: (context, state) => const FeedScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/generate',
                builder: (context, state) => const GenerateScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/profile',
                builder: (context, state) => const ProfileScreen(),
              ),
            ],
          ),
        ],
      ),
    ],
  );
}

class AuthStateListenable extends ChangeNotifier {
  AuthStateListenable(AsyncValue<void> authState) {
    if (!authState.isLoading) {
      notifyListeners();
    }
  }
}
