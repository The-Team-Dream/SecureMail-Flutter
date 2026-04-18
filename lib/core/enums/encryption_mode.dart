/// Unified encryption mode used across IMAP, SMTP, and UI.
///
/// Instead of having [ImapEncryption], [SmtpEncryption], and [EncryptionMode]
/// as separate enums, we use this single enum everywhere.
enum EncryptionMode {
  none,
  sslTls,
  startTls;

  /// Human-readable label for UI display.
  String get label => switch (this) {
        EncryptionMode.none => 'None',
        EncryptionMode.sslTls => 'SSL/TLS',
        EncryptionMode.startTls => 'STARTTLS',
      };
}
