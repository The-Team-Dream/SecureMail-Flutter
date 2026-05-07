class SessionModel {
  final int id;
  final String ipAddress;
  final String deviceOs;
  final String deviceBrowser;
  final String userAgent;
  final String loginAt;
  final String expiresAt;
  final bool isCurrent;

  SessionModel({
    required this.id,
    required this.ipAddress,
    required this.deviceOs,
    required this.deviceBrowser,
    required this.userAgent,
    required this.loginAt,
    required this.expiresAt,
    required this.isCurrent,
  });

  factory SessionModel.fromJson(Map<String, dynamic> json) {
    return SessionModel(
      id:            json['id'] as int,
      ipAddress:     json['ipAddress'] as String? ?? 'Unknown',
      deviceOs:      json['deviceOs'] as String? ?? 'Unknown',
      deviceBrowser: json['deviceBrowser'] as String? ?? 'Unknown',
      userAgent:     json['userAgent'] as String? ?? '',
      loginAt:       json['loginAt'] as String? ?? '',
      expiresAt:     json['expiresAt'] as String? ?? '',
      isCurrent:     json['isCurrent'] as bool? ?? false,
    );
  }
}
