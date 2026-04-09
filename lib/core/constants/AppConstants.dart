/// SecureMail — App-wide Constants
class AppConstants {
  AppConstants._();

  // ── App Info ──────────────────────────────────────────────
  static const String appName    = 'SecureMail';
  static const String appVersion = '1.0.0';

  // ── Assets ───────────────────────────────────────────────
  static const String logoPath       = 'assets/images/logo.png';
  static const String splashPath     = 'assets/images/splash.png';
  static const String placeholderImg = 'assets/images/placeholder.png';

  // ── SharedPreferences Keys ────────────────────────────────
  static const String keyThemeMode    = 'theme_mode';
  static const String keyAccessToken  = 'access_token';
  static const String keyRefreshToken = 'refresh_token';
  static const String keyUserEmail    = 'user_email';
  static const String keyRememberMe   = 'remember_me';

  // ── Secure Storage Keys ───────────────────────────────────
  static const String secureAccessToken  = 'secure_access_token';
  static const String secureRefreshToken = 'secure_refresh_token';

  // ── Pagination ────────────────────────────────────────────
  static const int defaultPageSize = 20;

  // ── Timeouts ──────────────────────────────────────────────
  static const int connectTimeoutMs = 15000;
  static const int receiveTimeoutMs = 15000;

  // ── Animation Durations ───────────────────────────────────
  static const Duration animFast   = Duration(milliseconds: 150);
  static const Duration animNormal = Duration(milliseconds: 300);
  static const Duration animSlow   = Duration(milliseconds: 500);
}