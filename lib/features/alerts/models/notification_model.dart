class NotificationModel {
  final int id;
  final int userId;
  final String type;
  final String title;
  final String message;
  final bool isRead;
  final Map<String, dynamic>? metadata;
  final int? mailBoxId;
  final int? emailId;
  final String createdAt;

  NotificationModel({
    required this.id,
    required this.userId,
    required this.type,
    required this.title,
    required this.message,
    required this.isRead,
    this.metadata,
    this.mailBoxId,
    this.emailId,
    required this.createdAt,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      id:          json['id'] as int,
      userId:      json['userId'] as int,
      type:        json['type'] as String? ?? 'SYSTEM',
      title:       json['title'] as String? ?? '',
      message:     json['message'] as String? ?? '',
      isRead:      json['isRead'] as bool? ?? false,
      metadata:    json['metadata'] as Map<String, dynamic>?,
      mailBoxId:   json['mailBoxId'] as int?,
      emailId:     json['emailId'] as int?,
      createdAt:   json['createdAt'] as String? ?? '',
    );
  }
}
