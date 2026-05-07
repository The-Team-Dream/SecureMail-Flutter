import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:securemail/features/auth/screens/SplashScreen.dart';
import 'package:securemail/features/auth/screens/LoginScreen.dart';
import 'package:securemail/features/auth/screens/RegisterScreen.dart';
import 'package:securemail/features/auth/screens/ForgotPasswordScreen.dart';
import 'package:securemail/features/auth/screens/OtpScreen.dart';
import 'package:securemail/features/dashboard/screens/DashboardScreen.dart';
import 'package:securemail/features/mailboxes/models/mailbox_model.dart';
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
import 'package:securemail/features/mailboxes/screens/add_mailbox/OAuthCallbackScreen.dart';


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

  static String inbox(int id) => '/mailboxes/$id/inbox';
  static String sent(int id) => '/mailboxes/$id/sent';
  static String spam(int id) => '/mailboxes/$id/spam';
  static String malware(int id) => '/mailboxes/$id/malware';
  static String phishing(int id) => '/mailboxes/$id/phishing';
  static String reports(int id) => '/mailboxes/$id/reports';
  static String mailboxSettings(int id) => '/mailboxes/$id/settings';
  static String compose(int id) => '/mailboxes/$id/compose';
  static String messageDetail(int id) => '/mailboxes/$id/message-detail';

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
  
  static const oauthCallback = '/mailboxes/:provider/callback';
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
                  path: ':mailboxId/inbox',
                  builder: (context, state) {
                    final id = int.parse(state.pathParameters['mailboxId']!);
                    return InboxScreen(mailboxId: id);
                  },
                ),
                GoRoute(
                  path: ':mailboxId/sent',
                  builder: (context, state) {
                    final id = int.parse(state.pathParameters['mailboxId']!);
                    return SentScreen(mailboxId: id);
                  },
                ),
                GoRoute(
                  path: ':mailboxId/spam',
                  builder: (context, state) {
                    final id = int.parse(state.pathParameters['mailboxId']!);
                    return SpamScreen(mailboxId: id);
                  },
                ),
                GoRoute(
                  path: ':mailboxId/malware',
                  builder: (context, state) {
                    final id = int.parse(state.pathParameters['mailboxId']!);
                    return MalwareScreen(mailboxId: id);
                  },
                ),
                GoRoute(
                  path: ':mailboxId/phishing',
                  builder: (context, state) {
                    final id = int.parse(state.pathParameters['mailboxId']!);
                    return PhishingScreen(mailboxId: id);
                  },
                ),
                GoRoute(
                  path: ':mailboxId/reports',
                  builder: (context, state) {
                    final id = int.parse(state.pathParameters['mailboxId']!);
                    return ReportsScreen(mailboxId: id);
                  },
                ),
                GoRoute(
                  path: ':mailboxId/settings',
                  builder: (context, state) {
                    final id = int.parse(state.pathParameters['mailboxId']!);
                    return MailboxSettingsScreen(mailboxId: id);
                  },
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
      path: '/mailboxes/:mailboxId/compose',
      builder: (context, state) {
        final mailboxId = int.parse(state.pathParameters['mailboxId']!);
        if (state.extra is Map<String, dynamic>) {
          final extra = state.extra as Map<String, dynamic>;
          return ComposeScreen(
            mailboxId: mailboxId,
            initialRecipient: extra['recipient'] as String?,
            initialSubject: extra['subject'] as String?,
          );
        }
        return ComposeScreen(mailboxId: mailboxId);
      },
    ),
    GoRoute(
      path: '/mailboxes/:mailboxId/message-detail',
      builder: (context, state) {
        final mailboxId = int.parse(state.pathParameters['mailboxId']!);
        if (state.extra is Map<String, dynamic>) {
          final extra = state.extra as Map<String, dynamic>;
          final message = extra['message'] as MailboxMessage;
          final folder = extra['folder'] as String?;
          return MessageDetailScreen(
            mailboxId: mailboxId,
            message: message, 
            currentFolder: folder,
          );
        }
        final message = state.extra as MailboxMessage;
        return MessageDetailScreen(
          mailboxId: mailboxId,
          message: message,
        );
      },
    ),

    
    // ── OAuth Callback ────────────────────────────────────────
    GoRoute(
      path: AppRoutes.oauthCallback,
      builder: (context, state) {
        final providerStr = state.pathParameters['provider'];
        final code = state.uri.queryParameters['code'];
        
        final provider = providerStr == 'gmail' 
            ? MailboxProvider.gmail 
            : MailboxProvider.outlook;
            
        return OAuthCallbackScreen(code: code, provider: provider);
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
