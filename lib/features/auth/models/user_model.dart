class UserModel {
  final int id;
  final String email;
  final String username;
  final String? avatar;
  final bool isVerified;
  final bool totpEnabled;
  final String provider;
  final String role;
  final String createdAt;

  UserModel({
    required this.id,
    required this.email,
    required this.username,
    this.avatar,
    required this.isVerified,
    required this.totpEnabled,
    required this.provider,
    required this.role,
    required this.createdAt,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id:           json['id'] as int,
      email:        json['email'] as String,
      username:     json['username'] as String,
      avatar:       json['avatar'] as String?,
      isVerified:   json['isVerified'] as bool? ?? false,
      totpEnabled:  json['totpEnabled'] as bool? ?? false,
      provider:     json['provider'] as String? ?? 'local',
      role:         json['role'] as String? ?? 'USER',
      createdAt:    json['createdAt'] as String? ?? '',
    );
  }
}
