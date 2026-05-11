import 'package:flutter/foundation.dart';

/// SecureMail — API Endpoints & Configuration
class ApiConstants {
  ApiConstants._();

  // ── Base URLs ─────────────────────────────────────────────
  static const String baseUrl = 'https://api.securemail.com';

  // يتم استخدام localhost للويب والـ IP الفعلي للهاتف
  static const String baseUrlDev =
      kIsWeb ? 'http://localhost:3000' : 'http://10.0.0.106:3000';

  // ── Auth ──────────────────────────────────────────────────
  static const String login = '/auth/login';
  static const String register = '/auth/register';
  static const String logout = '/auth/logout';
  static const String refreshToken = '/auth/refresh';
  static const String forgotPassword = '/auth/forget-password';
  static const String resetPassword = '/auth/reset-password';
  static const String verifyRegisterOtp = '/auth/verify-register-otp';
  static const String resendOtp = '/auth/resend-otp';
  static const String verify2Fa = '/auth/verify-2fa';
  static const String googleAuth = '/auth/google/login';
  static const String googleAuthMobile = '/auth/google/mobile';
  static const String outlookAuth = '/auth/outlook';

  // ── User ──────────────────────────────────────────────────
  static const String profile = '/user/profile';

  // ── User Settings ─────────────────────────────────────────
  static const String userSettings = '/user-settings';
  static const String updateProfile = '/user-settings/profile';
  static const String changePassword = '/user-settings/password';
  static const String updateTheme = '/user-settings/theme';
  static const String updateNotifications = '/user-settings/notifications';
  static const String setup2Fa = '/user-settings/2fa/setup';
  static const String enable2Fa = '/user-settings/2fa/enable';
  static const String disable2Fa = '/user-settings/2fa/disable';

  // ── Sessions ──────────────────────────────────────────────
  static const String sessions = '/sessions';
  static String sessionById(int id) => '/sessions/$id';

  // ── Mailboxes ─────────────────────────────────────────────
  static const String mailboxes = '/mailboxes';
  static String mailboxById(int id) => '/mailboxes/$id';
  static const String connectImap = '/mailboxes/imap';
  static const String connectGmail = '/mailboxes/gmail';
  static const String connectOutlook = '/mailboxes/outlook';
  static const String gmailAuthUrl = '/mailboxes/gmail/auth-url';
  static const String outlookAuthUrl = '/mailboxes/outlook/auth-url';
  static String mailboxReports(int id) => '/mailboxes/$id/reports';
  static String syncMailbox(int id) => '/mailboxes/$id/sync';

  // ── Emails ────────────────────────────────────────────────
  static String inbox(int mailboxId) => '/mailboxes/$mailboxId/inbox';
  static String sent(int mailboxId) => '/mailboxes/$mailboxId/sent';
  static String spam(int mailboxId) => '/mailboxes/$mailboxId/spam';
  static String phishing(int mailboxId) => '/mailboxes/$mailboxId/phishing';
  static String malware(int mailboxId) => '/mailboxes/$mailboxId/malware';
  static String trash(int mailboxId) => '/mailboxes/$mailboxId/trash';
  static String starred(int mailboxId) => '/mailboxes/$mailboxId/starred';
  static String searchEmails(int mailboxId) => '/mailboxes/$mailboxId/search';
  static String emailById(int mailboxId, int emailId) =>
      '/mailboxes/$mailboxId/emails/$emailId';
  static String markEmailRead(int mailboxId, int emailId) =>
      '/mailboxes/$mailboxId/emails/$emailId/read';
  static String markEmailStarred(int mailboxId, int emailId) =>
      '/mailboxes/$mailboxId/emails/$emailId/star';
  static String deleteEmail(int mailboxId, int emailId) =>
      '/mailboxes/$mailboxId/emails/$emailId';
  static String reportEmail(int mailboxId, int emailId) =>
      '/mailboxes/$mailboxId/emails/$emailId/report';
  static String reclassifyEmail(int mailboxId, int emailId) =>
      '/mailboxes/$mailboxId/emails/$emailId/reclassify';
  static String sendEmail(int mailboxId) => '/mailboxes/$mailboxId/send';
  static String replyEmail(int mailboxId, int emailId) =>
      '/mailboxes/$mailboxId/emails/$emailId/reply';
  static String forwardEmail(int mailboxId, int emailId) =>
      '/mailboxes/$mailboxId/emails/$emailId/forward';

  // ── Notifications ─────────────────────────────────────────
  static const String notifications = '/notifications';
  static const String notificationsUnreadCount = '/notifications/unread-count';
  static const String notificationsReadAll = '/notifications/read-all';
  static String notificationById(int id) => '/notifications/$id';
  static String notificationMarkRead(int id) => '/notifications/$id/read';

  // ── Analytics ─────────────────────────────────────────────
  static const String analyticsOverview = '/analytics/overview';
  static const String analyticsActivity = '/analytics/activity';
  static String analyticsMailbox(int id) => '/analytics/mailboxes/$id';

  // ── Headers ───────────────────────────────────────────────
  static const String headerAuthorization = 'Authorization';
  static const String headerContentType = 'Content-Type';
  static const String headerAccept = 'Accept';
  static const String bearerPrefix = 'Bearer ';
  static const String jsonContentType = 'application/json';

  // ── Timeouts ──────────────────────────────────────────────
  static const int connectTimeoutMs = 30000;
  static const int receiveTimeoutMs = 30000;
}
