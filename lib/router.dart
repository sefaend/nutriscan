import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:nutri_scan/features/app.dart';
import 'package:nutri_scan/features/auth/login_screen.dart';
import 'package:nutri_scan/features/auth/signup_screen.dart';
import 'package:nutri_scan/features/product/product_screen.dart';
import 'package:nutri_scan/features/profile/profile_screen.dart';
import 'package:nutri_scan/features/scanner/scanner_screen.dart';

import 'features/home/home_screen.dart';

final _rooterKey = GlobalKey<NavigatorState>();

class AppRoutes {
  AppRoutes._();

  static const String home = "/";
  static const String scanner = "/scanner";
  static const String profile = "/profile";
  static const String login = "/login";
  static const String signup = "/signup";
  static const String product = "/product/:barcode";
}

final router = GoRouter(
  initialLocation: AppRoutes.home,
  navigatorKey: _rooterKey,
  routes: [
    GoRoute(
      parentNavigatorKey: _rooterKey,
      path: AppRoutes.login,
      builder: (context, state) => const LoginScreen(),
    ),
    GoRoute(
      parentNavigatorKey: _rooterKey,
      path: AppRoutes.signup,
      builder: (context, state) => const SignupScreen(),
    ),
    GoRoute(
      parentNavigatorKey: _rooterKey,
      path: AppRoutes.product,
      builder: (context, state) =>
          ProductScreen(barcode: state.pathParameters['barcode']!),
    ),
    StatefulShellRoute.indexedStack(
      builder: (context, state, navigationShell) =>
          AppScreen(navigationShell: navigationShell),
      branches: [
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: AppRoutes.home,
              builder: (context, state) => const HomeScreen(),
            ),
          ],
        ),

        StatefulShellBranch(
          routes: [
            GoRoute(
              path: AppRoutes.scanner,
              builder: (context, state) => const ScannerScreen(),
            ),
          ],
        ),

        StatefulShellBranch(
          routes: [
            GoRoute(
              path: AppRoutes.profile,
              builder: (context, state) => const ProfileScreen(),
            ),
          ],
        ),
      ],
    ),
  ],
);
