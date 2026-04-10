import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:securemail/core/mock/mock_data.dart';

// ── State ──────────────────────────────────────────────────

class OtpState {
  const OtpState({
    this.isLoading      = false,
    this.isResending    = false,
    this.error,
    this.isVerified     = false,
    this.resendSuccess  = false,
  });

  final bool    isLoading;
  final bool    isResending;   // spinner منفصل لزرار الـ resend
  final String? error;
  final bool    isVerified;
  final bool    resendSuccess;

  OtpState copyWith({
    bool?    isLoading,
    bool?    isResending,
    String?  error,
    bool?    isVerified,
    bool?    resendSuccess,
    bool     clearError = false,
  }) {
    return OtpState(
      isLoading:     isLoading     ?? this.isLoading,
      isResending:   isResending   ?? this.isResending,
      error:         clearError ? null : error ?? this.error,
      isVerified:    isVerified    ?? this.isVerified,
      resendSuccess: resendSuccess ?? this.resendSuccess,
    );
  }
}

// ── Notifier ───────────────────────────────────────────────

class OtpNotifier extends StateNotifier<OtpState> {
  OtpNotifier() : super(const OtpState());

  // ── Verify Register OTP ───────────────────────────────────
  /// POST /auth/verify-register-otp
  /// Body: { email, otp }  ← otp: 6 digits numeric
  Future<bool> verifyOtp({
    required String email,
    required String otp,
  }) async {
    state = state.copyWith(isLoading: true, clearError: true);

    try {
      // TODO: استبدل بـ API call حقيقي
      // await ApiClient.instance.post(
      //   ApiConstants.verifyRegisterOtp,
      //   data: {'email': email, 'otp': otp},
      // );

      await MockData.simulate(MockData.mockVerifyOtpResponse);

      state = state.copyWith(isLoading: false, isVerified: true);
      return true;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error:     'Invalid or expired OTP. Please try again.',
      );
      return false;
    }
  }

  // ── Resend OTP ────────────────────────────────────────────
  /// POST /auth/register (بنبعت التسجيل تاني عشان يبعت OTP جديد)
  /// أو لو الـ Backend عنده endpoint منفصل نغيره
  Future<bool> resendOtp({required String email}) async {
    state = state.copyWith(
      isResending:   true,
      resendSuccess: false,
      clearError:    true,
    );

    try {
      // TODO: استبدل بـ API call حقيقي
      // await ApiClient.instance.post(
      //   ApiConstants.resendOtp,
      //   data: {'email': email},
      // );

      await MockData.simulate({'message': 'OTP resent successfully.'});

      state = state.copyWith(isResending: false, resendSuccess: true);
      return true;
    } catch (e) {
      state = state.copyWith(
        isResending: false,
        error:       'Failed to resend OTP. Please try again.',
      );
      return false;
    }
  }

  // ── Clear ─────────────────────────────────────────────────
  void clearError() => state = state.copyWith(clearError: true);

  void reset() => state = const OtpState();
}

// ── Provider ───────────────────────────────────────────────

final otpProvider = StateNotifierProvider<OtpNotifier, OtpState>(
  (ref) => OtpNotifier(),
);
