import 'dart:io';
import 'package:dio/dio.dart';
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

  UserProfile copyWith({
    String? id,
    String? email,
    String? username,
    String? createdAt,
    bool? twoFactorEnabled,
    String? themeMode,
    String? avatarUrl,
    int? storageUsedPercent,
    int? storageUsedMb,
    int? storageTotalMb,
  }) {
    return UserProfile(
      id: id ?? this.id,
      email: email ?? this.email,
      username: username ?? this.username,
      createdAt: createdAt ?? this.createdAt,
      twoFactorEnabled: twoFactorEnabled ?? this.twoFactorEnabled,
      themeMode: themeMode ?? this.themeMode,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      storageUsedPercent: storageUsedPercent ?? this.storageUsedPercent,
      storageUsedMb: storageUsedMb ?? this.storageUsedMb,
      storageTotalMb: storageTotalMb ?? this.storageTotalMb,
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
    this.isUpdatingAvatar = false,
    this.error,
    this.profile,
    this.localImage,
  });

  final bool isLoading;
  final bool isLoggingOut;
  final bool isUpdatingAvatar;
  final String? error;
  final UserProfile? profile;
  final File? localImage;

  ProfileState copyWith({
    bool? isLoading,
    bool? isLoggingOut,
    bool? isUpdatingAvatar,
    String? error,
    UserProfile? profile,
    File? localImage,
    bool clearError = false,
    bool clearLocalImage = false,
  }) {
    return ProfileState(
      isLoading: isLoading ?? this.isLoading,
      isLoggingOut: isLoggingOut ?? this.isLoggingOut,
      isUpdatingAvatar: isUpdatingAvatar ?? this.isUpdatingAvatar,
      error: clearError ? null : error ?? this.error,
      profile: profile ?? this.profile,
      localImage: clearLocalImage ? null : localImage ?? this.localImage,
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

  // ── Update Username ─────────────────────────────────
  Future<void> updateUsername(String newName) async {
    if (state.profile == null) return;

    // Update locally first for immediate feedback
    final oldProfile = state.profile!;
    state = state.copyWith(
      profile: oldProfile.copyWith(username: newName),
    );

    try {
      // TODO: استبدل بـ API call حقيقي
      // await ApiClient.instance.put(ApiConstants.updateProfile, data: {'username': newName});

      await Future.delayed(const Duration(milliseconds: 500)); // mock delay
    } catch (e) {
      // Revert if API fails
      state = state.copyWith(
        profile: oldProfile,
        error: 'Failed to update username. Please try again.',
      );
    }
  }

  // ── Update Avatar ────────────────────────────────────
  /// POST /user/profile/avatar (Multipart)
  Future<void> updateAvatar(File imageFile) async {
    state = state.copyWith(
      isUpdatingAvatar: true,
      clearError: true,
      localImage: imageFile,
    );

    try {
      // simulate API multipart data
      // final formData = FormData.fromMap({
      //   'avatar': await MultipartFile.fromFile(imageFile.path),
      // });
      // final response = await ApiClient.instance.post(ApiConstants.uploadAvatar, data: formData);
      // final newAvatarUrl = response.data['avatarUrl'];

      // Mock delay
      await Future.delayed(const Duration(seconds: 2));

      // For mock, we'll simulate a successful upload.
      // In a real app, the server would return a URL like:
      // final newAvatarUrl = response.data['avatarUrl'];

      // For now, we will keep the local image to show the user's actual selection
      // and just clear the loading state.

      if (state.profile != null) {
        state = state.copyWith(
          isUpdatingAvatar: false,
          // profile: state.profile!.copyWith(avatarUrl: newAvatarUrl), // Real API would do this
        );
      }
    } catch (e) {
      state = state.copyWith(
        isUpdatingAvatar: false,
        error: 'Failed to update avatar. Please try again.',
      );
    }
  }

  // ── Delete Avatar ────────────────────────────────────
  Future<void> deleteAvatar() async {
    state = state.copyWith(isUpdatingAvatar: true, clearError: true);

    try {
      // TODO: استبدل بـ API call حقيقي
      // await ApiClient.instance.delete(ApiConstants.deleteAvatar);

      await Future.delayed(const Duration(milliseconds: 800)); // mock delay

      if (state.profile != null) {
        state = state.copyWith(
          isUpdatingAvatar: false,
          profile: state.profile!.copyWith(avatarUrl: null),
          clearLocalImage: true,
        );
      }
    } catch (e) {
      state = state.copyWith(
        isUpdatingAvatar: false,
        error: 'Failed to remove avatar. Please try again.',
      );
    }
  }

  // ── Clear Error ───────────────────────────────────────
  void clearError() => state = state.copyWith(clearError: true);
}

// ══════════════════════════════════════════════════════════
// PROVIDER
// ══════════════════════════════════════════════════════════

final profileProvider = StateNotifierProvider<ProfileNotifier, ProfileState>(
  (ref) => ProfileNotifier(),
);
