import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:securemail/core/constants/AppConstants.dart';
import 'package:securemail/core/network/api_client.dart';
import 'package:securemail/core/constants/ApiConstants.dart';
import 'package:dio/dio.dart';

// ── State ──────────────────────────────────────────────────

class OtpState {
  const OtpState({
    this.isLoading = false,
    this.isResending = false,
    this.error,
    this.isVerified = false,
    this.resendSuccess = false,
  });

  final bool isLoading;
  final bool isResending;
  final String? error;
  final bool isVerified;
  final bool resendSuccess;

  OtpState copyWith({
    bool? isLoading,
    bool? isResending,
    String? error,
    bool? isVerified,
    bool? resendSuccess,
    bool clearError = false,
  }) {
    return OtpState(
      isLoading:     isLoading     ?? this.isLoading,
      isResending:   isResending   ?? this.isResending,
      error:         clearError    ? null : error ?? this.error,
      isVerified:    isVerified    ?? this.isVerified,
      resendSuccess: resendSuccess ?? this.resendSuccess,
    );
  }
}

// ── Notifier ───────────────────────────────────────────────

class OtpNotifier extends StateNotifier<OtpState> {
  OtpNotifier() : super(const OtpState());

  final _storage = const FlutterSecureStorage();

  // ── Verify Register OTP ───────────────────────────────────
  /// POST /auth/verify-register-otp
  /// Body: { email, otp }
  Future<bool> verifyOtp({
    required String email,
    required String otp,
  }) async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      await ApiClient.post(
        ApiConstants.verifyRegisterOtp,
        data: {'email': email, 'otp': otp},
      );
      state = state.copyWith(isLoading: false, isVerified: true);
      return true;
    } on DioException catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: _extractError(e, 'Invalid or expired OTP. Please try again.'),
      );
      return false;
    } catch (_) {
      state = state.copyWith(
        isLoading: false,
        error: 'Invalid or expired OTP. Please try again.',
      );
      return false;
    }
  }

  // ── Resend OTP ────────────────────────────────────────────
  /// POST /auth/resend-otp
  /// Body: { email }
  Future<bool> resendOtp({required String email}) async {
    state = state.copyWith(
      isResending: true,
      resendSuccess: false,
      clearError: true,
    );
    try {
      await ApiClient.post(
        ApiConstants.resendOtp,
        data: {'email': email},
      );
      state = state.copyWith(isResending: false, resendSuccess: true);
      return true;
    } on DioException catch (e) {
      state = state.copyWith(
        isResending: false,
        error: _extractError(e, 'Failed to resend OTP. Please try again.'),
      );
      return false;
    } catch (_) {
      state = state.copyWith(
        isResending: false,
        error: 'Failed to resend OTP. Please try again.',
      );
      return false;
    }
  }

  // ── Clear ─────────────────────────────────────────────────
  void clearError() => state = state.copyWith(clearError: true);
  void reset() => state = const OtpState();

  // ── Helper ───────────────────────────────────────────────
  String _extractError(DioException e, String fallback) {
    try {
      final data = e.response?.data;
      if (data is Map) return data['message'] as String? ?? fallback;
    } catch (_) {}
    return fallback;
  }
}

// ── Provider ───────────────────────────────────────────────

final otpProvider = StateNotifierProvider<OtpNotifier, OtpState>(
  (ref) => OtpNotifier(),
);
