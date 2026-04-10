import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:securemail/core/constants/AppConstants.dart';
import 'package:securemail/core/mock/mock_data.dart';

// ── State ──────────────────────────────────────────────────

class AuthState {
  const AuthState({
    this.isLoading = false,
    this.error,
    this.isAuthenticated = false,
    this.accessToken,
  });

  final bool    isLoading;
  final String? error;
  final bool    isAuthenticated;
  final String? accessToken;

  AuthState copyWith({
    bool?    isLoading,
    String?  error,
    bool?    isAuthenticated,
    String?  accessToken,
    bool     clearError = false,
  }) {
    return AuthState(
      isLoading:       isLoading       ?? this.isLoading,
      error:           clearError ? null : error ?? this.error,
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
      accessToken:     accessToken     ?? this.accessToken,
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
  Future<bool> login({
    required String email,
    required String password,
  }) async {
    state = state.copyWith(isLoading: true, clearError: true);

    try {
      // TODO: استبدل بـ API call حقيقي
      // final response = await ApiClient.instance.post(
      //   ApiConstants.login,
      //   data: {'email': email, 'password': password},
      // );
      // final data = response.data;

      final data = await MockData.simulate(MockData.mockLoginResponse);

      await _storage.write(
        key:   AppConstants.secureAccessToken,
        value: data['access_token'] as String,
      );
      await _storage.write(
        key:   AppConstants.secureRefreshToken,
        value: data['refresh_token'] as String,
      );

      state = state.copyWith(
        isLoading:       false,
        isAuthenticated: true,
        accessToken:     data['access_token'] as String,
      );

      return true;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error:     'Invalid email or password.',
      );
      return false;
    }
  }

  // ── Register ─────────────────────────────────────────────
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
      // TODO: استبدل بـ API call حقيقي
      // await ApiClient.instance.post(
      //   ApiConstants.register,
      //   data: {
      //     'email':           email,
      //     'password':        password,
      //     'confirmPassword': confirmPassword,
      //     'username':        username,
      //   },
      // );

      await MockData.simulate(MockData.mockRegisterResponse);

      state = state.copyWith(isLoading: false);
      return true;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error:     'Registration failed. Please try again.',
      );
      return false;
    }
  }

  // ── Forget Password ───────────────────────────────────────
  /// POST /auth/forget-password
  /// Body: { email }
  Future<bool> forgetPassword({required String email}) async {
    state = state.copyWith(isLoading: true, clearError: true);

    try {
      // TODO: استبدل بـ API call حقيقي
      // await ApiClient.instance.post(
      //   ApiConstants.forgotPassword,
      //   data: {'email': email},
      // );

      await MockData.simulate(MockData.mockForgetPasswordResponse);

      state = state.copyWith(isLoading: false);
      return true;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error:     'Failed to send reset link. Please try again.',
      );
      return false;
    }
  }

  // ── Reset Password ────────────────────────────────────────
  /// POST /auth/reset-password
  /// Body: { resetPasswordToken, newPassword }
  Future<bool> resetPassword({
    required String resetPasswordToken,
    required String newPassword,
  }) async {
    state = state.copyWith(isLoading: true, clearError: true);

    try {
      // TODO: استبدل بـ API call حقيقي
      // await ApiClient.instance.post(
      //   ApiConstants.resetPassword,
      //   data: {
      //     'resetPasswordToken': resetPasswordToken,
      //     'newPassword':        newPassword,
      //   },
      // );

      await MockData.simulate(MockData.mockResetPasswordResponse);

      state = state.copyWith(isLoading: false);
      return true;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error:     'Failed to reset password. Please try again.',
      );
      return false;
    }
  }

  // ── Logout ────────────────────────────────────────────────
  /// POST /auth/logout
  Future<void> logout() async {
    try {
      // TODO: استبدل بـ API call حقيقي
      // await ApiClient.instance.post(ApiConstants.logout);
    } catch (_) {
      // حتى لو الـ API fail، بنعمل local logout
    } finally {
      await _storage.deleteAll();
      state = const AuthState();
    }
  }

  // ── Check Auth ────────────────────────────────────────────
  /// بيتحقق لو في token محفوظ عند فتح الـ app
  Future<bool> checkAuth() async {
    final token = await _storage.read(key: AppConstants.secureAccessToken);
    if (token != null) {
      state = state.copyWith(
        isAuthenticated: true,
        accessToken:     token,
      );
      return true;
    }
    return false;
  }

  // ── Clear Error ───────────────────────────────────────────
  void clearError() => state = state.copyWith(clearError: true);
}

// ── Provider ───────────────────────────────────────────────

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>(
  (ref) => AuthNotifier(),
);
