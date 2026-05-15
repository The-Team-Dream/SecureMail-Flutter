import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:securemail/core/constants/AppConstants.dart';
import 'package:securemail/core/constants/ApiConstants.dart';
import 'package:securemail/core/network/api_client.dart';
import 'package:securemail/core/network/socket_service.dart';
import 'package:dio/dio.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:securemail/features/mailboxes/providers/mailboxes_provider.dart';
import 'package:securemail/features/mailbox_detail/providers/messages_provider.dart';
import 'package:securemail/features/alerts/providers/alerts_provider.dart';
import 'package:securemail/features/analytics/providers/analytics_provider.dart';
import 'package:securemail/features/mailboxes/providers/security_report_provider.dart';
import 'package:securemail/features/profile/providers/profile_provider.dart';

// ── State ──────────────────────────────────────────────────

class AuthState {
  const AuthState({
    this.isLoading = false,
    this.error,
    this.isAuthenticated = false,
    this.accessToken,
    this.requires2FA = false,
    this.tempToken,
    this.requiresVerification = false,
    this.pendingEmail,
  });

  final bool isLoading;
  final String? error;
  final bool isAuthenticated;
  final String? accessToken;
  final bool requires2FA;
  final String? tempToken;

  /// true عندما يحاول المستخدم تسجيل الدخول بدون تفعيل الإيميل
  final bool requiresVerification;

  /// الإيميل المنتظر التحقق (لتمريره لصفحة OTP)
  final String? pendingEmail;

  AuthState copyWith({
    bool? isLoading,
    String? error,
    bool? isAuthenticated,
    String? accessToken,
    bool? requires2FA,
    String? tempToken,
    bool? requiresVerification,
    String? pendingEmail,
    bool clearError = false,
    bool clearTempToken = false,
    bool clearVerification = false,
  }) {
    return AuthState(
      isLoading: isLoading ?? this.isLoading,
      error: clearError ? null : error ?? this.error,
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
      accessToken: accessToken ?? this.accessToken,
      requires2FA: requires2FA ?? this.requires2FA,
      tempToken: clearTempToken ? null : tempToken ?? this.tempToken,
      requiresVerification: clearVerification
          ? false
          : requiresVerification ?? this.requiresVerification,
      pendingEmail:
          clearVerification ? null : pendingEmail ?? this.pendingEmail,
    );
  }
}

// ── Notifier ───────────────────────────────────────────────

class AuthNotifier extends StateNotifier<AuthState> {
  final Ref _ref;
  AuthNotifier(this._ref) : super(const AuthState());

  final _storage = const FlutterSecureStorage();
  final GoogleSignIn _googleSignIn = GoogleSignIn(
    serverClientId:
        '932834989443-ogaoin4l6ma2aimjn8sdut2bdpjejg16.apps.googleusercontent.com',
    scopes: ['email', 'profile'],
  );

  // ── Login ────────────────────────────────────────────────
  /// POST /auth/login
  /// Body: { email, password }
  /// Response: { token } أو { requires2FA: true, tempToken }
  Future<bool> login({
    required String email,
    required String password,
  }) async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final response = await ApiClient.post(
        ApiConstants.login,
        data: {'email': email, 'password': password},
      );
      final data = response.data['data'] as Map<String, dynamic>;

      // ── حالة الإيميل غير مفعّل — تحويل لصفحة OTP ───────
      if (data['requiresVerification'] == true) {
        state = state.copyWith(
          isLoading: false,
          requiresVerification: true,
          pendingEmail: data['email'] as String? ?? email,
        );
        return true;
      }

      // ── حالة الـ 2FA ────────────────────────────────────
      if (data['requires2FA'] == true) {
        state = state.copyWith(
          isLoading: false,
          requires2FA: true,
          tempToken: data['tempToken'] as String?,
        );
        return true;
      }

      // ── حالة الـ login العادي ────────────────────────────
      final token = data['token'] as String;
      debugPrint('[AuthNotifier] Saving token to storage...');
      await _storage.write(key: AppConstants.secureAccessToken, value: token);
      debugPrint('[AuthNotifier] Token saved successfully');

      state = state.copyWith(
        isLoading: false,
        isAuthenticated: true,
        accessToken: token,
        requires2FA: false,
      );

      // Init Socket
      socketService.init(token);

      return true;
    } on DioException catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: _extractError(e, 'Invalid email or password.'),
      );
      return false;
    } catch (_) {
      state = state.copyWith(
          isLoading: false, error: 'Login failed. Please try again.');
      return false;
    }
  }

  // ── Google Login (Native) ─────────────────────────────────
  Future<bool> loginWithGoogle() async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      // Force account picker by signing out first
      await _googleSignIn.signOut();

      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        state = state.copyWith(isLoading: false);
        return false;
      }
      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;
      final String? idToken = googleAuth.idToken;
      if (idToken == null) {
        throw Exception('Failed to get ID Token from Google');
      }
      final response = await ApiClient.post(
        ApiConstants.googleAuthMobile,
        data: {'idToken': idToken},
      );
      final token = response.data['data']['token'] as String;
      debugPrint('[AuthNotifier] Saving Google token to storage...');
      await _storage.write(key: AppConstants.secureAccessToken, value: token);
      debugPrint('[AuthNotifier] Google token saved successfully');

      state = state.copyWith(
        isLoading: false,
        isAuthenticated: true,
        accessToken: token,
      );

      // Init Socket
      socketService.init(token);

      return true;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      return false;
    }
  }

  // ── Google Login (Browser Flow) ───────────────────────────
  Future<void> loginWithGoogleBrowser() async {
    final url = Uri.parse(
        '${ApiConstants.baseUrlDev}${ApiConstants.googleAuth}?clientType=mobile');
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    } else {
      state = state.copyWith(error: 'Could not launch browser');
    }
  }

  // ── Outlook Login (Browser Flow) ──────────────────────────
  Future<void> loginWithOutlook() async {
    final url = Uri.parse(
        '${ApiConstants.baseUrlDev}${ApiConstants.outlookAuth}?clientType=mobile');
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    } else {
      state = state.copyWith(error: 'Could not launch browser');
    }
  }

  // ── Verify 2FA ────────────────────────────────────────────
  /// POST /auth/verify-2fa
  /// Body: { tempToken, code }
  Future<bool> verify2FA({required String code}) async {
    final tempToken = state.tempToken;
    if (tempToken == null) return false;

    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final response = await ApiClient.post(
        ApiConstants.verify2Fa,
        data: {'tempToken': tempToken, 'code': code},
      );
      final token = response.data['data']['token'] as String;
      await _storage.write(key: AppConstants.secureAccessToken, value: token);

      state = state.copyWith(
        isLoading: false,
        isAuthenticated: true,
        accessToken: token,
        requires2FA: false,
        clearTempToken: true,
      );

      // Init Socket
      socketService.init(token);

      return true;
    } on DioException catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: _extractError(e, 'Invalid 2FA code.'),
      );
      return false;
    } catch (_) {
      state = state.copyWith(
          isLoading: false, error: 'Verification failed. Please try again.');
      return false;
    }
  }

  // ── Register ──────────────────────────────────────────────
  /// POST /auth/register
  /// Body: { email, password, confirmPassword, username }
  Future<bool> register({
    required String email,
    required String password,
    required String confirmPassword,
    required String username,
  }) async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      await ApiClient.post(
        ApiConstants.register,
        data: {
          'email': email,
          'password': password,
          'confirmPassword': confirmPassword,
          'username': username,
        },
      );
      state = state.copyWith(isLoading: false);
      return true;
    } on DioException catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: _extractError(e, 'Registration failed. Please try again.'),
      );
      return false;
    } catch (_) {
      state = state.copyWith(
          isLoading: false, error: 'Registration failed. Please try again.');
      return false;
    }
  }

  // ── Forget Password ───────────────────────────────────────
  /// POST /auth/forget-password
  /// Body: { email }
  Future<bool> forgetPassword({required String email}) async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      await ApiClient.post(
        ApiConstants.forgotPassword,
        data: {
          'email': email,
          'clientType': 'mobile',
        },
      );
      state = state.copyWith(isLoading: false);
      return true;
    } on DioException catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: _extractError(e, 'Failed to send reset link. Please try again.'),
      );
      return false;
    } catch (_) {
      state = state.copyWith(
          isLoading: false,
          error: 'Failed to send reset link. Please try again.');
      return false;
    }
  }

  // ── Reset Password ────────────────────────────────────────
  /// POST /auth/reset-password
  /// Body: { resetPasswordToken, newPassword, confirmPassword }
  Future<bool> resetPassword({
    required String token,
    required String newPassword,
  }) async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      await ApiClient.post(
        ApiConstants.resetPassword,
        data: {
          'resetPasswordToken': token,
          'newPassword': newPassword,
          'confirmPassword': newPassword, // نرسله مرتين للمطابقة في الباكند
        },
      );
      state = state.copyWith(isLoading: false);
      return true;
    } on DioException catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: _extractError(e, 'Failed to reset password. Please try again.'),
      );
      return false;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      return false;
    }
  }

  // ── Logout ────────────────────────────────────────────────
  /// POST /auth/logout
  Future<void> logout() async {
    try {
      await ApiClient.post(ApiConstants.logout);
    } catch (_) {
      // حتى لو الـ API فشلت، امسح الـ storage دايماً
    } finally {
      // Clean up Google session too
      try {
        await _googleSignIn.signOut();
      } catch (_) {}

      await _storage.deleteAll();
      socketService.disconnect();
      ApiClient.reset(); // Force Dio recreation

      // ── Invalidate all data providers to clear cache for the next user ──
      _ref.invalidate(mailboxesProvider);
      _ref.invalidate(messagesProvider);
      _ref.invalidate(alertsProvider);
      _ref.invalidate(unreadCountProvider);
      _ref.invalidate(analyticsOverviewProvider);
      _ref.invalidate(analyticsActivityProvider('daily'));
      _ref.invalidate(analyticsActivityProvider('weekly'));
      _ref.invalidate(analyticsActivityProvider('monthly'));
      _ref.invalidate(securityReportsProvider);

      state = const AuthState();
    }
  }

  // ── Check Auth ────────────────────────────────────────────
  /// بيتشال لما التطبيق يفتح — يقرأ الـ token من الـ storage
  Future<bool> checkAuth() async {
    final token = await _storage.read(key: AppConstants.secureAccessToken);
    if (token != null && token.isNotEmpty) {
      state = state.copyWith(isAuthenticated: true, accessToken: token);
      socketService.init(token);
      return true;
    }
    return false;
  }

  // ── Clear Verification Flag ───────────────────────────────
  void clearVerificationFlag() =>
      state = state.copyWith(clearVerification: true);

  // ── Clear Error ───────────────────────────────────────────
  void clearError() => state = state.copyWith(clearError: true);

  // ── Set External Token ────────────────────────────────────
  /// Used for deep links (Google OAuth browser flow)
  Future<void> setExternalToken(String token) async {
    await _storage.write(key: 'token', value: token);
    state = state.copyWith(isLoading: false, clearError: true);
    await checkAuth(); // تحديث حالة الـ Auth
  }

  // ── Helper ────────────────────────────────────────────────
  String _extractError(DioException e, String fallback) {
    try {
      final data = e.response?.data;
      if (data is Map) return data['message'] as String? ?? fallback;
    } catch (_) {}
    return fallback;
  }
}

// ── Provider ───────────────────────────────────────────────

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>(
  (ref) => AuthNotifier(ref),
);
