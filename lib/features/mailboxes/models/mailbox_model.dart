import 'package:timeago/timeago.dart' as timeago;

enum MailboxProvider { gmail, outlook, imap }

enum MailboxSyncStatus { syncing, synced, reauth, error }

class MailboxModel {
  final int id;
  final String displayName;
  final String emailAddress;
  final String providerString; // القيمة الخام من الباكند
  final bool isActive;
  final bool pushNotificationsEnabled;
  final String? lastSyncedAt;
  final String createdAt;
  final bool hasCredentials;
  final int emailCount;
  final int storageUsed;
  final int storageLimit;

  // ── Getters للواجهة ─────────────────────────────────────
  String get email => emailAddress;
  double get syncProgress => 1.0;
  DateTime? get lastSyncAt => lastSyncedAt != null ? DateTime.tryParse(lastSyncedAt!) : null;

  double get storagePercent => storageLimit > 0 ? (storageUsed / storageLimit) : 0.0;

  MailboxSyncStatus get syncStatus => MailboxSyncStatus.synced;

  String get lastSyncLabel {
    if (lastSyncedAt == null) return 'Never';
    final date = DateTime.tryParse(lastSyncedAt!);
    if (date == null) return 'Unknown';
    return timeago.format(date);
  }

  MailboxProvider get provider {
    final p = providerString.toLowerCase();
    if (p.contains('gmail')) return MailboxProvider.gmail;
    if (p.contains('outlook')) return MailboxProvider.outlook;
    return MailboxProvider.imap;
  }

  MailboxModel({
    required this.id,
    required this.displayName,
    required this.emailAddress,
    required this.providerString,
    required this.isActive,
    required this.pushNotificationsEnabled,
    this.lastSyncedAt,
    required this.createdAt,
    required this.hasCredentials,
    required this.emailCount,
    this.storageUsed = 0,
    this.storageLimit = 0,
  });

  factory MailboxModel.fromJson(Map<String, dynamic> json) {
    return MailboxModel(
      id:                       json['id'] as int,
      displayName:              json['displayName'] as String? ?? '',
      emailAddress:             json['emailAddress'] as String? ?? '',
      providerString:           json['provider'] as String? ?? 'IMAP',
      isActive:                 json['isActive'] as bool? ?? true,
      pushNotificationsEnabled: json['pushNotificationsEnabled'] as bool? ?? true,
      lastSyncedAt:             json['lastSyncedAt'] as String?,
      createdAt:                json['createdAt'] as String? ?? '',
      hasCredentials:           json['hasCredentials'] as bool? ?? false,
      emailCount:               json['emailCount'] as int? ?? 0,
      storageUsed:              json['storageUsed'] as int? ?? 0,
      storageLimit:             json['storageLimit'] as int? ?? 0,
    );
  }
}
