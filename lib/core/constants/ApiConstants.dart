/// SecureMail — API Endpoints & Configuration
class ApiConstants {
  ApiConstants._();

  // ── Base URLs ─────────────────────────────────────────────
  static const String baseUrl    = 'https://api.securemail.com/v1';
  static const String baseUrlDev = 'http://10.0.2.2:8000/api/v1'; // Android emulator localhost

  // ── Auth ──────────────────────────────────────────────────
  static const String login         = '/auth/login';
  static const String register      = '/auth/register';
  static const String logout        = '/auth/logout';
  static const String refreshToken  = '/auth/refresh';
  static const String forgotPassword= '/auth/forgot-password';
  static const String resetPassword = '/auth/reset-password';
  static const String googleAuth    = '/auth/google';
  static const String outlookAuth   = '/auth/outlook';

  // ── Emails ────────────────────────────────────────────────
  static const String emails        = '/emails';
  static const String inbox         = '/emails/inbox';
  static const String sent          = '/emails/sent';
  static const String drafts        = '/emails/drafts';
  static const String starred       = '/emails/starred';
  static const String trash         = '/emails/trash';
  static const String spam          = '/emails/spam';
  static const String search        = '/emails/search';
  static const String sendEmail     = '/emails/send';

  // ── User ──────────────────────────────────────────────────
  static const String profile       = '/user/profile';
  static const String updateProfile = '/user/profile/update';
  static const String uploadAvatar  = '/user/profile/avatar';
  static const String contacts      = '/user/contacts';

  // ── Notifications ─────────────────────────────────────────
  static const String registerDevice   = '/notifications/register';
  static const String unregisterDevice = '/notifications/unregister';

  // ── Headers ───────────────────────────────────────────────
  static const String headerAuthorization = 'Authorization';
  static const String headerContentType   = 'Content-Type';
  static const String headerAccept        = 'Accept';
  static const String bearerPrefix        = 'Bearer ';
  static const String jsonContentType     = 'application/json';

  // time outs
static const int connectTimeoutMs = 15000;
static const int receiveTimeoutMs = 15000;
}