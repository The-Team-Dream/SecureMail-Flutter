import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:securemail/features/auth/screens/SplashScreen.dart';
import 'package:securemail/features/auth/screens/LoginScreen.dart';
import 'package:securemail/features/auth/screens/RegisterScreen.dart';
import 'package:securemail/features/auth/screens/ForgotPasswordScreen.dart';
import 'package:securemail/features/auth/screens/OtpScreen.dart';
import 'package:securemail/features/dashboard/screens/DashboardScreen.dart';
import 'package:securemail/features/profile/screens/ProfileScreen.dart';
import 'package:securemail/features/mailboxes/screens/MailboxesScreen.dart';
import 'package:securemail/features/alerts/screens/AlertsScreen.dart';
import 'package:securemail/features/analytics/screens/AnalyticsScreen.dart';
import 'package:securemail/features/mailbox_detail/models/mailbox_message.dart';
import 'package:securemail/features/mailbox_detail/screens/InboxScreen.dart';
import 'package:securemail/features/mailbox_detail/screens/SentScreen.dart';
import 'package:securemail/features/mailbox_detail/screens/SpamScreen.dart';
import 'package:securemail/features/mailbox_detail/screens/MalwareScreen.dart';
import 'package:securemail/features/mailbox_detail/screens/PhishingScreen.dart';
import 'package:securemail/features/mailbox_detail/screens/ReportsScreen.dart';
import 'package:securemail/features/mailbox_detail/screens/MailboxSettingsScreen.dart';
import 'package:securemail/features/mailbox_detail/screens/ComposeScreen.dart';
import 'package:securemail/features/mailbox_detail/screens/MessageDetailScreen.dart';
import 'package:securemail/features/settings/screens/ChangePasswordScreen.dart';
import 'package:securemail/features/settings/screens/EditProfileScreen.dart';
import 'package:securemail/features/settings/screens/LoggedInDevicesScreen.dart';
import 'package:securemail/features/settings/screens/NotificationsSettingsScreen.dart';
import 'package:securemail/features/settings/screens/PrivacySecurityScreen.dart';
import 'package:securemail/features/settings/screens/SettingsScreen.dart';

class AppRoutes {
  AppRoutes._();

  // ── Route Names ───────────────────────────────────────────
  static const splash = '/';
  static const login = '/login';
  static const register = '/register';
  static const forgotPassword = '/forgot-password';
  static const otp = '/otp';

  // Dashboard Tabs
  static const profile = '/profile';
  static const analytics = '/analytics';
  static const mailboxes = '/mailboxes';
  static const alerts = '/alerts';
  static const settings = '/settings';

  static const inbox = '/mailboxes/inbox';
  static const sent = '/mailboxes/sent';
  static const spam = '/mailboxes/spam';
  static const malware = '/mailboxes/malware';
  static const phishing = '/mailboxes/phishing';
  static const reports = '/mailboxes/reports';
  static const mailboxSettings = '/mailboxes/settings';
  static const compose = '/mailboxes/compose';
  static const messageDetail = '/mailboxes/message-detail';

  static const editProfile = '/editProfile';
  static const changePassword = '/changePassword';
  static const twoFactorAuth = '/twoFactorAuth';
  static const loggedInDevices = '/loggedInDevices';
  static const notificationsSettings = '/notificationsSettings';
  static const privacySecurity = '/privacySecurity';

  static const addMailboxStep1 = '/add-mailbox/step1';
  static const addMailboxStep2 = '/add-mailbox/step2';
  static const addMailboxStep3 = '/add-mailbox/step3';
  static const addMailboxStep4 = '/add-mailbox/step4';
  static const addMailboxStep5 = '/add-mailbox/step5';

  // Keep dashboard as an alias or just use mailboxes
  static const dashboard = mailboxes;
}

final appRouter = GoRouter(
  initialLocation: AppRoutes.splash,
  routes: [
    // ── Splash ───────────────────────────────────────────────
    GoRoute(
      path: AppRoutes.splash,
      builder: (_, __) => const SplashScreen(),
    ),

    // ── Login ────────────────────────────────────────────────
    GoRoute(
      path: AppRoutes.login,
      builder: (_, __) => const LoginScreen(),
    ),

    // ── Register ─────────────────────────────────────────────
    GoRoute(
      path: AppRoutes.register,
      builder: (_, __) => const RegisterScreen(),
    ),

    // ── Forgot Password ───────────────────────────────────────
    GoRoute(
      path: AppRoutes.forgotPassword,
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
              builder: (context, state) => const MailboxesScreen(),
              routes: [
                GoRoute(
                  path: 'inbox',
                  builder: (context, state) => const InboxScreen(),
                ),
                GoRoute(
                  path: 'sent',
                  builder: (context, state) => const SentScreen(),
                ),
                GoRoute(
                  path: 'spam',
                  builder: (context, state) => const SpamScreen(),
                ),
                GoRoute(
                  path: 'malware',
                  builder: (context, state) => const MalwareScreen(),
                ),
                GoRoute(
                  path: 'phishing',
                  builder: (context, state) => const PhishingScreen(),
                ),
                GoRoute(
                  path: 'reports',
                  builder: (context, state) => const ReportsScreen(),
                ),
                GoRoute(
                  path: 'settings',
                  builder: (context, state) => const MailboxSettingsScreen(),
                ),
              ],
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
        // 4: Settings (Config)
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
      path: AppRoutes.loggedInDevices,
      builder: (context, state) => const LoggedInDevicesScreen(),
    ),
    GoRoute(
      path: AppRoutes.notificationsSettings,
      builder: (context, state) => const NotificationsSettingsScreen(),
    ),
    GoRoute(
      path: AppRoutes.privacySecurity,
      builder: (context, state) => const PrivacySecurityScreen(),
    ),

    // ── Add Mailbox Flow ──────────────────────────────────────
    GoRoute(
      path: AppRoutes.compose,
      builder: (context, state) {
        if (state.extra is Map<String, dynamic>) {
          final extra = state.extra as Map<String, dynamic>;
          return ComposeScreen(
            initialRecipient: extra['recipient'] as String?,
            initialSubject: extra['subject'] as String?,
          );
        }
        return const ComposeScreen();
      },
    ),
    GoRoute(
      path: AppRoutes.messageDetail,
      builder: (context, state) {
        if (state.extra is Map<String, dynamic>) {
          final extra = state.extra as Map<String, dynamic>;
          final message = extra['message'] as MailboxMessage;
          final folder = extra['folder'] as String?;
          return MessageDetailScreen(message: message, currentFolder: folder);
        }
        final message = state.extra as MailboxMessage;
        return MessageDetailScreen(message: message);
      },
    ),
  ],

  // ── Error Page ────────────────────────────────────────────
  errorBuilder: (context, state) => Scaffold(
    body: Center(
      child: Text('Page not found: ${state.error}'),
    ),
  ),
);
