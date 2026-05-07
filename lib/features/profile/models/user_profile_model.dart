import 'package:securemail/core/constants/ApiConstants.dart';

class UserProfileModel {
  final int id;
  final String email;
  final String username;
  final String? avatar;
  final bool isVerified;
  final bool totpEnabled;
  final String provider;
  final String role;
  final String createdAt;
  final UserSettingsModel? settings;

  // ── Helpers للواجهة ─────────────────────────────────────
  int get storageUsedPercent => 85; 
  String? get avatarUrl {
    if (avatar == null) return null;
    if (avatar!.startsWith('http')) return avatar;
    return '${ApiConstants.baseUrlDev}/uploads/$avatar';
  }

  UserProfileModel({
    required this.id,
    required this.email,
    required this.username,
    this.avatar,
    required this.isVerified,
    required this.totpEnabled,
    required this.provider,
    required this.role,
    required this.createdAt,
    this.settings,
  });

  factory UserProfileModel.fromJson(Map<String, dynamic> json) {
    return UserProfileModel(
      id:          json['id'] as int,
      email:       json['email'] as String,
      username:    json['username'] as String,
      avatar:      json['avatar'] as String?,
      isVerified:  json['isVerified'] as bool? ?? false,
      totpEnabled: json['totpEnabled'] as bool? ?? false,
      provider:    json['provider'] as String? ?? 'local',
      role:        json['role'] as String? ?? 'USER',
      createdAt:   json['createdAt'] as String? ?? '',
      settings:    json['settings'] != null
          ? UserSettingsModel.fromJson(json['settings'] as Map<String, dynamic>)
          : null,
    );
  }
}

class UserSettingsModel {
  final String themeMode;
  final bool notificationsEnabled;

  UserSettingsModel({
    required this.themeMode,
    required this.notificationsEnabled,
  });

  factory UserSettingsModel.fromJson(Map<String, dynamic> json) {
    return UserSettingsModel(
      themeMode:             json['themeMode'] as String? ?? 'LIGHT',
      notificationsEnabled:  json['notificationsEnabled'] as bool? ?? true,
    );
  }
}
