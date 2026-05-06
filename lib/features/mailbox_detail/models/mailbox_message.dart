import 'package:flutter/material.dart';

class MailboxMessage {
  const MailboxMessage({
    required this.id,
    required this.initials,
    required this.sender,
    required this.subject,
    required this.preview,
    required this.timeLabel,
    required this.badgeLabel,
    required this.badgeColor,
    this.avatarColor = const Color(0xFF0B2B23),
    this.isActive = false,
  });

  final String id;
  final String initials;
  final String sender;
  final String subject;
  final String preview;
  final String timeLabel;
  final String badgeLabel;
  final Color badgeColor;
  final Color avatarColor;
  final bool isActive;
}

class MailboxMockMessages {
  MailboxMockMessages._();

  static const inbox = [
    MailboxMessage(
      id: 'msg_001',
      initials: 'AS',
      sender: 'Amazon Security',
      subject: 'Suspicious login detected',
      preview: 'Your AWS account was accessed from a new IP location.',
      timeLabel: '10:42 AM',
      badgeLabel: 'MODERATE RISK',
      badgeColor: Color(0xFFF4D03F),
      isActive: true,
    ),
    MailboxMessage(
      id: 'msg_002',
      initials: 'BN',
      sender: 'Binance Support',
      subject: 'Withdrawal Confirmation',
      preview: 'You have successfully withdrawn 0.45 BTC to your wallet.',
      timeLabel: '09:15 AM',
      badgeLabel: 'VERIFIED SENDER',
      badgeColor: Color(0xFF8CEB2F),
    ),
    MailboxMessage(
      id: 'msg_003',
      initials: 'JH',
      sender: 'Julian H. (Vault)',
      subject: 'Encrypted Payload Attached',
      preview: 'Please use the private key shared in person to decrypt.',
      timeLabel: 'Yesterday',
      badgeLabel: 'END-TO-END ENCRYPTED',
      badgeColor: Color(0xFF8CEB2F),
    ),
    MailboxMessage(
      id: 'msg_004',
      initials: '??',
      sender: 'service@paypal.co',
      subject: 'Action Required: Your account is limited',
      preview: 'We have detected unusual activity on your account.',
      timeLabel: 'May 12',
      badgeLabel: 'HIGH THREAT - PHISHING LINK',
      badgeColor: Color(0xFFFF5252),
      avatarColor: Color(0xFF3A1716),
    ),
    MailboxMessage(
      id: 'msg_005',
      initials: 'GH',
      sender: 'GitHub Enterprise',
      subject: 'Security Alert: Exposed Secret',
      preview: 'We found a plaintext key in your repository core-service.',
      timeLabel: 'May 11',
      badgeLabel: 'SYSTEM NOTIFICATION',
      badgeColor: Color(0xFFC3E7DF),
    ),
  ];

  static const sent = [
    MailboxMessage(
      id: 'msg_006',
      initials: 'JD',
      sender: 'To: security@company.com',
      subject: 'Re: Q1 Security Report',
      preview: 'Thanks for the report. I will review the flagged items.',
      timeLabel: '10:00 AM',
      badgeLabel: 'SIGNED AND SENT',
      badgeColor: Color(0xFF8CEB2F),
    ),
    MailboxMessage(
      id: 'msg_007',
      initials: 'JD',
      sender: 'To: julian@vault.local',
      subject: 'Vault key rotation',
      preview: 'The new public key has been attached for validation.',
      timeLabel: 'Yesterday',
      badgeLabel: 'ENCRYPTED',
      badgeColor: Color(0xFF8CEB2F),
    ),
  ];

  static const spam = [
    MailboxMessage(
      id: 'msg_008',
      initials: '!!',
      sender: 'promo@spammy-deals.com',
      subject: 'You have won a prize!',
      preview: 'Congratulations. Claim your suspicious reward now.',
      timeLabel: 'Mar 12',
      badgeLabel: 'SPAM QUARANTINED',
      badgeColor: Color(0xFFFFB74D),
      avatarColor: Color(0xFF34240B),
    ),
    MailboxMessage(
      id: 'msg_009',
      initials: 'AD',
      sender: 'alerts@bulkmailer.net',
      subject: 'Final offer expires today',
      preview: 'Repeated sender failed mailbox trust checks.',
      timeLabel: 'Mar 10',
      badgeLabel: 'BULK SENDER',
      badgeColor: Color(0xFFFFB74D),
      avatarColor: Color(0xFF34240B),
    ),
  ];

  static const malware = [
    MailboxMessage(
      id: 'msg_010',
      initials: 'EX',
      sender: 'external.invoice@corp-pay.com',
      subject: 'Invoice payload blocked',
      preview: 'Attachment contained a macro signature match.',
      timeLabel: '08:44 AM',
      badgeLabel: 'MALWARE BLOCKED',
      badgeColor: Color(0xFFFF5252),
      avatarColor: Color(0xFF3A1716),
    ),
  ];

  static const phishing = [
    MailboxMessage(
      id: 'msg_011',
      initials: '??',
      sender: 'support@fake-bank-verify.com',
      subject: 'URGENT: Verify your account now',
      preview: 'The link destination did not match the sender domain.',
      timeLabel: 'Mar 13',
      badgeLabel: 'PHISHING DETECTED',
      badgeColor: Color(0xFFFF5252),
      avatarColor: Color(0xFF3A1716),
    ),
    MailboxMessage(
      id: 'msg_012',
      initials: 'PP',
      sender: 'service@paypaI.co',
      subject: 'Account access limited',
      preview: 'Lookalike domain and credential harvest pattern blocked.',
      timeLabel: 'May 12',
      badgeLabel: 'HIGH THREAT',
      badgeColor: Color(0xFFFF5252),
      avatarColor: Color(0xFF3A1716),
    ),
  ];
}
