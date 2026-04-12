import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:securemail/features/auth/screens/SplashScreen.dart';
import 'package:securemail/features/auth/screens/LoginScreen.dart';
import 'package:securemail/features/auth/screens/RegisterScreen.dart';
import 'package:securemail/features/auth/screens/ForgotPasswordScreen.dart';
import 'package:securemail/features/auth/screens/OtpScreen.dart';
import 'package:securemail/features/dashboard/screens/DashboardScreen.dart';

import 'package:securemail/features/profile/screens/ProfileScreen.dart';
import 'package:securemail/features/analytics/screens/AnalyticsScreen.dart';
import 'package:securemail/features/mailboxes/screens/MailboxesScreen.dart';
import 'package:securemail/features/alerts/screens/AlertsScreen.dart';
import 'package:securemail/features/settings/screens/ChangePasswordScreen.dart';
import 'package:securemail/features/settings/screens/EditProfileScreen.dart';
import 'package:securemail/features/settings/screens/SettingsScreen.dart';
import 'package:securemail/features/settings/screens/TwoFactorScreen.dart';

class AppRoutes {
  AppRoutes._();

  // ── Route Names ───────────────────────────────────────────
  static const splash         = '/';
  static const login          = '/login';
  static const register       = '/register';
  static const forgotPassword = '/forgot-password';
  static const otp            = '/otp';

  // Dashboard Tabs
  static const profile        = '/profile';
  static const analytics      = '/analytics';
  static const mailboxes      = '/mailboxes';
  static const alerts         = '/alerts';
  static const settings       = '/settings';
  static const editProfile    = '/editProfile';
  static const changePassword = '/changePassword';
  static const twoFactorAuth  = '/twoFactorAuth';
  
  // Keep dashboard as an alias or just use mailboxes
  static const dashboard      = mailboxes;
}

final appRouter = GoRouter(
  initialLocation: AppRoutes.splash,
  routes: [

    // ── Splash ───────────────────────────────────────────────
    GoRoute(
      path:    AppRoutes.splash,
      builder: (_, __) => const SplashScreen(),
    ),

    // ── Login ────────────────────────────────────────────────
    GoRoute(
      path:    AppRoutes.login,
      builder: (_, __) => const LoginScreen(),
    ),

    // ── Register ─────────────────────────────────────────────
    GoRoute(
      path:    AppRoutes.register,
      builder: (_, __) => const RegisterScreen(),
    ),

    // ── Forgot Password ───────────────────────────────────────
    GoRoute(
      path:    AppRoutes.forgotPassword,
      builder: (_, __) => const ForgotPasswordScreen(),
    ),

    // ── OTP ───────────────────────────────────────────────────
    GoRoute(
      path: AppRoutes.otp,
      builder: (context, state) {
        final email = state.extra as String? ?? '';
        return OtpScreen(email: email);
      },
    ),

    // ── Dashboard (StatefulShellRoute) ────────────────────────
    StatefulShellRoute.indexedStack(
      builder: (context, state, navigationShell) {
        return NavbarRoots(navigationShell: navigationShell);
      },
      branches: [
        // 0: Profile
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: AppRoutes.profile,
              builder: (context, state) => const Profilescreen(),
            ),
          ],
        ),
        // 1: Analytics
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: AppRoutes.analytics,
              builder: (context, state) => const Analyticsscreen(),
            ),
          ],
        ),
        // 2: Mailboxes
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: AppRoutes.mailboxes,
              builder: (context, state) => const Mailboxesscreen(),
            ),
          ],
        ),
        // 3: Alerts
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: AppRoutes.alerts,
              builder: (context, state) => const Alertsscreen(),
            ),
          ],
        ),
        // 4: Settings
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: AppRoutes.settings,
              builder: (context, state) => const Settingsscreen(),
            ),
          ],
        ),
      ],
    ),
    GoRoute(
      path: AppRoutes.editProfile,
      builder: (context, state) => const EditProfileScreen(),
    ),
    GoRoute(
      path: AppRoutes.changePassword,
      builder: (context, state) => const ChangePasswordScreen(),
    ),
    GoRoute(
      path: AppRoutes.twoFactorAuth,
      builder: (context, state) => const TwoFactorScreen(),
    ),
  ],

  // ── Error Page ────────────────────────────────────────────
  errorBuilder: (context, state) => Scaffold(
    body: Center(
      child: Text('Page not found: ${state.error}'),
    ),
  ),
);
