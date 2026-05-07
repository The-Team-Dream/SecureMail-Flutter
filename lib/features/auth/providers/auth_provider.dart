import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:securemail/core/constants/AppConstants.dart';
import 'package:securemail/core/network/api_client.dart';
import 'package:securemail/core/constants/ApiConstants.dart';
import 'package:dio/dio.dart';

// ── State ──────────────────────────────────────────────────

class AuthState {
  const AuthState({
    this.isLoading = false,
    this.error,
    this.isAuthenticated = false,
    this.accessToken,
    this.requires2FA = false,
    this.tempToken,
  });

  final bool isLoading;
  final String? error;
  final bool isAuthenticated;
  final String? accessToken;
  final bool requires2FA;
  final String? tempToken;

  AuthState copyWith({
    bool? isLoading,
    String? error,
    bool? isAuthenticated,
    String? accessToken,
    bool? requires2FA,
    String? tempToken,
    bool clearError = false,
    bool clearTempToken = false,
  }) {
    return AuthState(
      isLoading:       isLoading       ?? this.isLoading,
      error:           clearError      ? null : error ?? this.error,
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
      accessToken:     accessToken     ?? this.accessToken,
      requires2FA:     requires2FA     ?? this.requires2FA,
      tempToken:       clearTempToken  ? null : tempToken ?? this.tempToken,
    );
  }
}

// ── Notifier ───────────────────────────────────────────────

class AuthNotifier extends StateNotifier<AuthState> {
  AuthNotifier() : super(const AuthState());

  final _storage = const FlutterSecureStorage();

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

      // ── حالة الـ 2FA ────────────────────────────────────
      if (data['requires2FA'] == true) {
        state = state.copyWith(
          isLoading:  false,
          requires2FA: true,
          tempToken:  data['tempToken'] as String?,
        );
        return true;
      }

      // ── حالة الـ login العادي ────────────────────────────
      final token = data['token'] as String;
      await _storage.write(key: AppConstants.secureAccessToken, value: token);

      state = state.copyWith(
        isLoading:       false,
        isAuthenticated: true,
        accessToken:     token,
        requires2FA:     false,
      );
      return true;
    } on DioException catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: _extractError(e, 'Invalid email or password.'),
      );
      return false;
    } catch (_) {
      state = state.copyWith(isLoading: false, error: 'Login failed. Please try again.');
      return false;
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
        isLoading:       false,
        isAuthenticated: true,
        accessToken:     token,
        requires2FA:     false,
        clearTempToken:  true,
      );
      return true;
    } on DioException catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: _extractError(e, 'Invalid 2FA code.'),
      );
      return false;
    } catch (_) {
      state = state.copyWith(isLoading: false, error: 'Verification failed. Please try again.');
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
          'email':           email,
          'password':        password,
          'confirmPassword': confirmPassword,
          'username':        username,
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
      state = state.copyWith(isLoading: false, error: 'Registration failed. Please try again.');
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
        data: {'email': email},
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
      state = state.copyWith(isLoading: false, error: 'Failed to send reset link. Please try again.');
      return false;
    }
  }

  // ── Reset Password ────────────────────────────────────────
  /// POST /auth/reset-password
  /// Body: { resetPasswordToken, newPassword, confirmPassword }
  Future<bool> resetPassword({
    required String resetPasswordToken,
    required String newPassword,
    required String confirmPassword,
  }) async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      await ApiClient.post(
        ApiConstants.resetPassword,
        data: {
          'resetPasswordToken': resetPasswordToken,
          'newPassword':        newPassword,
          'confirmPassword':    confirmPassword,
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
    } catch (_) {
      state = state.copyWith(isLoading: false, error: 'Failed to reset password. Please try again.');
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
      await _storage.deleteAll();
      state = const AuthState();
    }
  }

  // ── Check Auth ────────────────────────────────────────────
  /// بيتشال لما التطبيق يفتح — يقرأ الـ token من الـ storage
  Future<bool> checkAuth() async {
    final token = await _storage.read(key: AppConstants.secureAccessToken);
    if (token != null && token.isNotEmpty) {
      state = state.copyWith(isAuthenticated: true, accessToken: token);
      return true;
    }
    return false;
  }

  // ── Clear Error ───────────────────────────────────────────
  void clearError() => state = state.copyWith(clearError: true);

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
  (ref) => AuthNotifier(),
);