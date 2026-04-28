import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:securemail/core/mock/mock_data.dart';

// ══════════════════════════════════════════════════════════
// MODEL
// ══════════════════════════════════════════════════════════

class UserProfile {
  const UserProfile({
    required this.id,
    required this.email,
    required this.username,
    required this.createdAt,
    required this.twoFactorEnabled,
    required this.themeMode,
    this.avatarUrl,
    this.storageUsedPercent = 85,
    this.storageUsedMb = 2176,
    this.storageTotalMb = 2560,
  });

  final String id;
  final String email;
  final String username;
  final String createdAt;
  final bool twoFactorEnabled;
  final String themeMode;
  final String? avatarUrl;
  final int storageUsedPercent;
  final int storageUsedMb;
  final int storageTotalMb;

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      id: json['id'] as String,
      email: json['email'] as String,
      username: json['username'] as String,
      createdAt: json['createdAt'] as String,
      twoFactorEnabled: json['twoFactorEnabled'] as bool,
      themeMode: json['themeMode'] as String,
      avatarUrl: json['avatarUrl'] as String?,
      storageUsedPercent: json['storageUsedPercent'] as int? ?? 85,
      storageUsedMb: json['storageUsedMb'] as int? ?? 2176,
      storageTotalMb: json['storageTotalMb'] as int? ?? 2560,
    );
  }
}

// ══════════════════════════════════════════════════════════
// STATE
// ══════════════════════════════════════════════════════════

class ProfileState {
  const ProfileState({
    this.isLoading = false,
    this.isLoggingOut = false,
    this.error,
    this.profile,
  });

  final bool isLoading;
  final bool isLoggingOut;
  final String? error;
  final UserProfile? profile;

  ProfileState copyWith({
    bool? isLoading,
    bool? isLoggingOut,
    String? error,
    UserProfile? profile,
    bool clearError = false,
  }) {
    return ProfileState(
      isLoading: isLoading ?? this.isLoading,
      isLoggingOut: isLoggingOut ?? this.isLoggingOut,
      error: clearError ? null : error ?? this.error,
      profile: profile ?? this.profile,
    );
  }
}

// ══════════════════════════════════════════════════════════
// NOTIFIER
// ══════════════════════════════════════════════════════════

class ProfileNotifier extends StateNotifier<ProfileState> {
  ProfileNotifier() : super(const ProfileState()) {
    fetchProfile();
  }

  // ── Fetch Profile ─────────────────────────────────────
  /// GET /user/profile
  Future<void> fetchProfile() async {
    state = state.copyWith(isLoading: true, clearError: true);

    try {
      // TODO: استبدل بـ API call حقيقي
      // final response = await ApiClient.instance.get(ApiConstants.profile);
      // final profile = UserProfile.fromJson(response.data as Map<String, dynamic>);

      final data = await MockData.simulate(
        Map<String, dynamic>.from(MockData.mockUser),
      );

      final profile = UserProfile.fromJson(data);

      state = state.copyWith(isLoading: false, profile: profile);
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Failed to load profile. Please try again.',
      );
    }
  }

  // ── Logout ────────────────────────────────────────────
  /// POST /auth/logout
  Future<bool> logout() async {
    state = state.copyWith(isLoggingOut: true, clearError: true);

    try {
      // TODO: استبدل بـ API call حقيقي
      // await ApiClient.instance.post(ApiConstants.logout);
      // await _storage.deleteAll();

      await Future.delayed(const Duration(milliseconds: 900)); // mock delay

      state = state.copyWith(isLoggingOut: false);
      return true;
    } catch (e) {
      state = state.copyWith(
        isLoggingOut: false,
        error: 'Logout failed. Please try again.',
      );
      return false;
    }
  }

  // ── Refresh ───────────────────────────────────────────
  Future<void> refresh() => fetchProfile();

  // ── Clear Error ───────────────────────────────────────
  void clearError() => state = state.copyWith(clearError: true);
}

// ══════════════════════════════════════════════════════════
// PROVIDER
// ══════════════════════════════════════════════════════════

final profileProvider = StateNotifierProvider<ProfileNotifier, ProfileState>(
  (ref) => ProfileNotifier(),
);
