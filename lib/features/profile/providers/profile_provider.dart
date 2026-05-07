import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:securemail/core/constants/AppConstants.dart';
import 'package:securemail/core/network/api_client.dart';
import 'package:securemail/core/constants/ApiConstants.dart';
import 'package:securemail/features/profile/models/user_profile_model.dart';
import 'package:dio/dio.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:http_parser/http_parser.dart';
import 'package:securemail/features/auth/providers/auth_provider.dart';




// ── State ──────────────────────────────────────────────────

class ProfileState {
  const ProfileState({
    this.isLoading = false,
    this.isUpdating = false,
    this.isUpdatingAvatar = false,
    this.isLoggingOut = false,
    this.error,
    this.profile,
    this.localImage,
  });

  final bool isLoading;
  final bool isUpdating;
  final bool isUpdatingAvatar;
  final bool isLoggingOut;
  final String? error;
  final UserProfileModel? profile;
  final File? localImage;


  ProfileState copyWith({
    bool? isLoading,
    bool? isUpdating,
    bool? isUpdatingAvatar,
    bool? isLoggingOut,
    String? error,
    UserProfileModel? profile,
    File? localImage,
    bool clearError = false,
    bool clearLocalImage = false,
  }) {
    return ProfileState(
      isLoading:        isLoading        ?? this.isLoading,
      isUpdating:       isUpdating       ?? this.isUpdating,
      isUpdatingAvatar: isUpdatingAvatar ?? this.isUpdatingAvatar,
      isLoggingOut:     isLoggingOut     ?? this.isLoggingOut,
      error:            clearError ? null : error ?? this.error,
      profile:          profile          ?? this.profile,
      localImage:       clearLocalImage ? null : localImage ?? this.localImage,
    );
  }

}

// ── Notifier ───────────────────────────────────────────────

class ProfileNotifier extends StateNotifier<ProfileState> {
  final Ref _ref;
  ProfileNotifier(this._ref) : super(const ProfileState()) {
    fetchProfile();
  }

  final _storage = const FlutterSecureStorage();

  void clearError() => state = state.copyWith(clearError: true);
  Future<void> refresh() => fetchProfile();


  // ── Fetch Profile ────────────────────────────────────────
  /// GET /user/profile
  Future<void> fetchProfile() async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final response = await ApiClient.get(ApiConstants.profile);
      final data = response.data['data'] as Map<String, dynamic>;
      final user = data['user'] as Map<String, dynamic>;
      state = state.copyWith(
        isLoading: false,
        profile: UserProfileModel.fromJson(user),
      );
    } on DioException catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: _extractError(e, 'Failed to load profile.'),
      );
    } catch (_) {
      state = state.copyWith(isLoading: false, error: 'Failed to load profile.');
    }
  }

  // ── Update Username ───────────────────────────────────────
  /// PATCH /user-settings/profile  (multipart)
  /// Body: { username? }
  Future<bool> updateUsername(String username) async {
    state = state.copyWith(isUpdating: true, clearError: true);
    try {
      final formData = FormData.fromMap({'username': username});
      await ApiClient.patch(
        ApiConstants.updateProfile,
        data: formData,
      );
      // Refresh profile with updated data
      await fetchProfile();
      state = state.copyWith(isUpdating: false);
      return true;
    } on DioException catch (e) {
      state = state.copyWith(
        isUpdating: false,
        error: _extractError(e, 'Failed to update username.'),
      );
      return false;
    } catch (_) {
      state = state.copyWith(isUpdating: false, error: 'Failed to update username.');
      return false;
    }
  }


  // ── Update Avatar ─────────────────────────────────────────

  /// PATCH /user-settings/profile  (multipart)
  Future<bool> updateAvatar(XFile imageFile) async {
    state = state.copyWith(
      isUpdatingAvatar: true,
      clearError: true,
    );
    try {
      final bytes = await imageFile.readAsBytes();
      final extension = imageFile.name.split('.').last.toLowerCase();
      final mimeType = extension == 'png' ? 'png' : 'jpeg';

      final formData = FormData.fromMap({
        'avatar': MultipartFile.fromBytes(
          bytes,
          filename: imageFile.name,
          contentType: MediaType('image', mimeType),
        ),
      });
      
      await ApiClient.patch(
        ApiConstants.updateProfile,
        data: formData,
      );
      
      await fetchProfile();
      state = state.copyWith(isUpdatingAvatar: false);
      return true;
    } on DioException catch (e) {
      state = state.copyWith(
        isUpdatingAvatar: false,
        error: _extractError(e, 'Failed to update avatar.'),
      );
      return false;
    } catch (e) {
      state = state.copyWith(
        isUpdatingAvatar: false,
        error: 'Failed to update avatar.',
      );
      return false;
    }
  }


  // ── Logout ────────────────────────────────────────────────
  Future<bool> logout() async {
    state = state.copyWith(isLoggingOut: true);
    try {
      final auth = _ref.read(authProvider.notifier);
      await auth.logout();
      state = state.copyWith(isLoggingOut: false);
      return true;
    } catch (_) {
      state = state.copyWith(isLoggingOut: false);
      return false;
    }
  }


  // ── Remove Avatar ─────────────────────────────────────────
  /// PATCH /user-settings/profile  { removeAvatar: true }
  Future<bool> removeAvatar() async {
    state = state.copyWith(isUpdating: true, clearError: true);
    try {
      final formData = FormData.fromMap({'removeAvatar': 'true'});
      await ApiClient.patch(
        ApiConstants.updateProfile,
        data: formData,
      );
      await fetchProfile();
      state = state.copyWith(isUpdating: false);
      return true;
    } on DioException catch (e) {
      state = state.copyWith(
        isUpdating: false,
        error: _extractError(e, 'Failed to remove avatar.'),
      );
      return false;
    } catch (_) {
      state = state.copyWith(isUpdating: false, error: 'Failed to remove avatar.');
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

final profileProvider = StateNotifierProvider<ProfileNotifier, ProfileState>(

  (ref) => ProfileNotifier(ref),
);
