class AuthResponseData {
  final String? token;
  final bool? requires2FA;
  final String? tempToken;

  AuthResponseData({
    this.token,
    this.requires2FA,
    this.tempToken,
  });

  factory AuthResponseData.fromJson(Map<String, dynamic> json) {
    return AuthResponseData(
      token: json['token'] as String?,
      requires2FA: json['requires2FA'] as bool?,
      tempToken: json['tempToken'] as String?,
    );
  }
}

class AuthResponse {
  final bool success;
  final String message;
  final AuthResponseData data;

  AuthResponse({
    required this.success,
    required this.message,
    required this.data,
  });

  factory AuthResponse.fromJson(Map<String, dynamic> json) {
    return AuthResponse(
      success: json['success'] as bool? ?? false,
      message: json['message'] as String? ?? '',
      data: AuthResponseData.fromJson(
        (json['data'] as Map<String, dynamic>?) ?? {},
      ),
    );
  }
}
