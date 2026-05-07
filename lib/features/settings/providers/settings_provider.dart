import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:securemail/core/network/api_client.dart';
import 'package:securemail/core/constants/ApiConstants.dart';
import 'package:dio/dio.dart';

// ── State ──────────────────────────────────────────────────

class SettingsState {
  const SettingsState({
    this.isLoading = false,
    this.isUpdating = false,
    this.error,
    this.themeMode = 'LIGHT',
    this.notificationsEnabled = true,
  });

  final bool isLoading;
  final bool isUpdating;
  final String? error;
  final String themeMode;
  final bool notificationsEnabled;

  SettingsState copyWith({
    bool? isLoading,
    bool? isUpdating,
    String? error,
    String? themeMode,
    bool? notificationsEnabled,
    bool clearError = false,
  }) {
    return SettingsState(
      isLoading:            isLoading            ?? this.isLoading,
      isUpdating:           isUpdating           ?? this.isUpdating,
      error:                clearError           ? null : error ?? this.error,
      themeMode:            themeMode            ?? this.themeMode,
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
    );
  }
}

// ── Notifier ───────────────────────────────────────────────

class SettingsNotifier extends StateNotifier<SettingsState> {
  SettingsNotifier() : super(const SettingsState()) {
    fetchSettings();
  }

  // ── Fetch Settings ────────────────────────────────────────
  /// GET /user-settings
  Future<void> fetchSettings() async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final response = await ApiClient.get(ApiConstants.userSettings);
      final data = response.data['data'];
      state = state.copyWith(
        isLoading:            false,
        themeMode:            data['themeMode'] as String? ?? 'LIGHT',
        notificationsEnabled: data['notificationsEnabled'] as bool? ?? true,
      );
    } catch (_) {
      state = state.copyWith(isLoading: false);
    }
  }

  // ── Update Theme ──────────────────────────────────────────
  /// PATCH /user-settings/theme
  Future<bool> updateTheme(String mode) async {
    state = state.copyWith(isUpdating: true, clearError: true);
    try {
      await ApiClient.patch(
        ApiConstants.updateTheme,
        data: {'themeMode': mode},
      );
      state = state.copyWith(isUpdating: false, themeMode: mode);
      return true;
    } catch (e) {
      state = state.copyWith(isUpdating: false);
      return false;
    }
  }

  // ── Update Notifications ──────────────────────────────────
  /// PATCH /user-settings/notifications
  Future<bool> updateNotifications(bool enabled) async {
    state = state.copyWith(isUpdating: true, clearError: true);
    try {
      await ApiClient.patch(
        ApiConstants.updateNotifications,
        data: {'notificationsEnabled': enabled},
      );
      state = state.copyWith(isUpdating: false, notificationsEnabled: enabled);
      return true;
    } catch (e) {
      state = state.copyWith(isUpdating: false);
      return false;
    }
  }

  // ── Change Password ───────────────────────────────────────
  /// PATCH /user-settings/password
  Future<bool> changePassword(String currentPassword, String newPassword) async {
    state = state.copyWith(isUpdating: true, clearError: true);
    try {
      await ApiClient.patch(
        ApiConstants.changePassword,
        data: {
          'currentPassword': currentPassword,
          'newPassword':     newPassword,
        },
      );
      state = state.copyWith(isUpdating: false);
      return true;
    } on DioException catch (e) {
      state = state.copyWith(
        isUpdating: false,
        error: _extractError(e, 'Failed to change password.'),
      );
      return false;
    } catch (_) {
      state = state.copyWith(isUpdating: false, error: 'Failed to change password.');
      return false;
    }
  }

  // ── 2FA Operations ────────────────────────────────────────
  
  /// POST /user-settings/2fa/setup
  Future<Map<String, dynamic>?> setup2FA() async {
    try {
      final response = await ApiClient.post(ApiConstants.setup2Fa);
      return response.data['data'] as Map<String, dynamic>;
    } catch (_) {
      return null;
    }
  }

  /// POST /user-settings/2fa/enable
  Future<bool> enable2FA(String code) async {
    try {
      await ApiClient.post(ApiConstants.enable2Fa, data: {'code': code});
      return true;
    } catch (_) {
      return false;
    }
  }

  /// POST /user-settings/2fa/disable
  Future<bool> disable2FA(String code) async {
    try {
      await ApiClient.post(ApiConstants.disable2Fa, data: {'code': code});
      return true;
    } catch (_) {
      return false;
    }
  }

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

final settingsProvider = StateNotifierProvider<SettingsNotifier, SettingsState>(
  (ref) => SettingsNotifier(),
);
