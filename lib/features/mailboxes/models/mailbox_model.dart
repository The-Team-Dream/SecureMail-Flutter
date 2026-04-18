import 'package:securemail/core/enums/encryption_mode.dart';

export 'package:securemail/core/enums/encryption_mode.dart';

enum MailboxProvider { gmail, outlook, imap }

enum MailboxSyncStatus { syncing, synced, reauth, error }

// ─── Mailbox Model ────────────────────────────────────────

class MailboxModel {
  const MailboxModel({
    required this.id,
    required this.displayName,
    required this.email,
    required this.provider,
    required this.syncStatus,
    this.syncProgress = 0.0,
    this.lastSyncAt,
    this.imapHost,
    this.imapPort,
    this.imapEncryption,
    this.smtpHost,
    this.smtpPort,
    this.smtpEncryption,
    this.syncFrequency,
    this.fetchLimit,
    this.securityScanEnabled = true,
  });

  final String id;
  final String displayName;
  final String email;
  final MailboxProvider provider;
  final MailboxSyncStatus syncStatus;
  final double syncProgress;
  final DateTime? lastSyncAt;
  final String? imapHost;
  final int? imapPort;
  final EncryptionMode? imapEncryption;
  final String? smtpHost;
  final int? smtpPort;
  final EncryptionMode? smtpEncryption;
  final String? syncFrequency;
  final int? fetchLimit;
  final bool securityScanEnabled;

  /// Fixed copyWith — uses the sentinel pattern so that passing `null`
  /// explicitly is distinguishable from "don't change this field".
  MailboxModel copyWith({
    String? id,
    String? displayName,
    String? email,
    MailboxProvider? provider,
    MailboxSyncStatus? syncStatus,
    double? syncProgress,
    DateTime? lastSyncAt,
    bool clearLastSyncAt = false,
    String? imapHost,
    int? imapPort,
    EncryptionMode? imapEncryption,
    String? smtpHost,
    int? smtpPort,
    EncryptionMode? smtpEncryption,
    String? syncFrequency,
    int? fetchLimit,
    bool? securityScanEnabled,
  }) {
    return MailboxModel(
      id: id ?? this.id,
      displayName: displayName ?? this.displayName,
      email: email ?? this.email,
      provider: provider ?? this.provider,
      syncStatus: syncStatus ?? this.syncStatus,
      syncProgress: syncProgress ?? this.syncProgress,
      lastSyncAt: clearLastSyncAt ? null : (lastSyncAt ?? this.lastSyncAt),
      imapHost: imapHost ?? this.imapHost,
      imapPort: imapPort ?? this.imapPort,
      imapEncryption: imapEncryption ?? this.imapEncryption,
      smtpHost: smtpHost ?? this.smtpHost,
      smtpPort: smtpPort ?? this.smtpPort,
      smtpEncryption: smtpEncryption ?? this.smtpEncryption,
      syncFrequency: syncFrequency ?? this.syncFrequency,
      fetchLimit: fetchLimit ?? this.fetchLimit,
      securityScanEnabled: securityScanEnabled ?? this.securityScanEnabled,
    );
  }

  String get lastSyncLabel {
    if (lastSyncAt == null) return 'Never';
    final diff = DateTime.now().difference(lastSyncAt!);
    if (diff.inSeconds < 60) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    return '${diff.inDays}d ago';
  }
}

// ─── Add Mailbox Form Data ────────────────────────────────

/// Sentinel object used by [AddMailboxFormData.copyWith] to distinguish
/// between "parameter not passed" and "parameter explicitly set to null".
const _sentinel = Object();

class AddMailboxFormData {
  AddMailboxFormData({
    this.displayName,
    this.provider,
    this.email,
    this.imapHost,
    this.imapPort,
    this.imapEncryption,
    this.imapPassword,
    this.smtpHost,
    this.smtpPort,
    this.smtpEncryption,
    this.smtpPassword,
    this.syncFrequency,
    this.fetchLimit,
    this.securityScanEnabled = true,
  });

  String? displayName;
  MailboxProvider? provider;
  String? email;
  String? imapHost;
  int? imapPort;
  EncryptionMode? imapEncryption;

  /// ⚠️ Password is stored temporarily in memory only.
  /// It should be sent directly to the API and never logged or persisted.
  String? imapPassword;

  String? smtpHost;
  int? smtpPort;
  EncryptionMode? smtpEncryption;

  /// ⚠️ Password is stored temporarily in memory only.
  /// It should be sent directly to the API and never logged or persisted.
  String? smtpPassword;

  String? syncFrequency;
  int? fetchLimit;
  bool securityScanEnabled;

  /// Fixed copyWith using the sentinel pattern.
  ///
  /// Without this, passing `null` explicitly (e.g. to reset a field)
  /// would be treated the same as not passing the parameter at all,
  /// because `null ?? this.field` always returns `this.field`.
  ///
  /// Now:
  /// - Omit a parameter → keeps the old value
  /// - Pass a value     → uses the new value
  /// - Pass `null`      → sets the field to `null`
  AddMailboxFormData copyWith({
    Object? displayName = _sentinel,
    Object? provider = _sentinel,
    Object? email = _sentinel,
    Object? imapHost = _sentinel,
    Object? imapPort = _sentinel,
    Object? imapEncryption = _sentinel,
    Object? imapPassword = _sentinel,
    Object? smtpHost = _sentinel,
    Object? smtpPort = _sentinel,
    Object? smtpEncryption = _sentinel,
    Object? smtpPassword = _sentinel,
    Object? syncFrequency = _sentinel,
    Object? fetchLimit = _sentinel,
    Object? securityScanEnabled = _sentinel,
  }) {
    return AddMailboxFormData(
      displayName: identical(displayName, _sentinel)
          ? this.displayName
          : displayName as String?,
      provider: identical(provider, _sentinel)
          ? this.provider
          : provider as MailboxProvider?,
      email: identical(email, _sentinel) ? this.email : email as String?,
      imapHost:
          identical(imapHost, _sentinel) ? this.imapHost : imapHost as String?,
      imapPort:
          identical(imapPort, _sentinel) ? this.imapPort : imapPort as int?,
      imapEncryption: identical(imapEncryption, _sentinel)
          ? this.imapEncryption
          : imapEncryption as EncryptionMode?,
      imapPassword: identical(imapPassword, _sentinel)
          ? this.imapPassword
          : imapPassword as String?,
      smtpHost:
          identical(smtpHost, _sentinel) ? this.smtpHost : smtpHost as String?,
      smtpPort:
          identical(smtpPort, _sentinel) ? this.smtpPort : smtpPort as int?,
      smtpEncryption: identical(smtpEncryption, _sentinel)
          ? this.smtpEncryption
          : smtpEncryption as EncryptionMode?,
      smtpPassword: identical(smtpPassword, _sentinel)
          ? this.smtpPassword
          : smtpPassword as String?,
      syncFrequency: identical(syncFrequency, _sentinel)
          ? this.syncFrequency
          : syncFrequency as String?,
      fetchLimit: identical(fetchLimit, _sentinel)
          ? this.fetchLimit
          : fetchLimit as int?,
      securityScanEnabled: identical(securityScanEnabled, _sentinel)
          ? this.securityScanEnabled
          : securityScanEnabled as bool,
    );
  }

  /// Never log passwords. This toString override ensures that
  /// accidental debug prints won't leak credentials.
  @override
  String toString() =>
      'AddMailboxFormData(displayName: $displayName, email: $email, '
      'provider: $provider, imapHost: $imapHost, smtpHost: $smtpHost, '
      'syncFrequency: $syncFrequency, fetchLimit: $fetchLimit, '
      'securityScanEnabled: $securityScanEnabled)';
}
