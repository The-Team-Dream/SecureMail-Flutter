/// SecureMail — Mock Data
/// بيانات وهمية بنفس شكل الـ API الحقيقي
/// لما نربط الـ API بنحذف الملف ده ونغير الـ providers بس
library;

class MockData {
  MockData._();

  // ══════════════════════════════════════════════════════════
  // AUTH
  // ══════════════════════════════════════════════════════════

  /// POST /auth/register
  /// Body: { email, password, confirmPassword, username }
  static const mockRegisterResponse = {
    'message': 'Registration successful. Please verify your email.',
  };

  /// POST /auth/login
  /// Body: { email, password }
  static const mockLoginResponse = {
    'access_token': 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.mock_access',
    'refresh_token': 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.mock_refresh',
  };

  /// POST /auth/verify-register-otp
  /// Body: { email, otp }  ← otp: 6 digits numeric only
  static const mockVerifyOtpResponse = {
    'message': 'OTP verified successfully.',
    'access_token': 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.mock_access',
    'refresh_token': 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.mock_refresh',
  };

  /// POST /auth/forget-password
  /// Body: { email }
  static const mockForgetPasswordResponse = {
    'message': 'Reset link sent to your email.',
  };

  /// POST /auth/reset-password
  /// Body: { resetPasswordToken, newPassword }
  /// newPassword: 8-32 chars, must have uppercase + lowercase + number
  static const mockResetPasswordResponse = {
    'message': 'Password reset successfully.',
  };

  /// POST /auth/verify-2fa  (Header: Authorization Bearer token)
  /// Body: { code }  ← TOTP code: exactly 6 digits
  static const mockVerify2FAResponse = {
    'message': '2FA verified successfully.',
    'access_token': 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.mock_access',
    'refresh_token': 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.mock_refresh',
  };

  // ══════════════════════════════════════════════════════════
  // USER
  // ══════════════════════════════════════════════════════════

  /// GET /user/profile
  static const mockUser = {
    'id': 'usr_001',
    'email': 'waad@securemail.com',
    'username': 'Waad_Dev',
    'createdAt': '2024-01-15T10:00:00Z',
    'twoFactorEnabled': false,
    'themeMode': 'DARK',
  };

  // ══════════════════════════════════════════════════════════
  // USER SETTINGS
  // ══════════════════════════════════════════════════════════

  /// GET /user-settings
  static const mockUserSettings = {
    'themeMode': 'DARK', // LIGHT | DARK
    'twoFactorEnabled': false,
    'notificationsEnabled': true,
    'emailNotifications': true,
    'pushNotifications': true,
  };

  /// PATCH /user-settings/profile
  /// Body: { username }  ← 2-50 chars
  static const mockEditProfileResponse = {
    'message': 'Profile updated successfully.',
  };

  /// PATCH /user-settings/password
  /// Body: { currentPassword, newPassword }
  /// newPassword: 8-32 chars, uppercase + lowercase + number
  static const mockChangePasswordResponse = {
    'message': 'Password changed successfully.',
  };

  /// PATCH /user-settings/theme
  /// Body: { themeMode }  ← 'LIGHT' | 'DARK'
  static const mockThemeResponse = {
    'message': 'Theme updated successfully.',
  };

  /// POST /user-settings/2fa/setup
  static const mock2FASetup = {
    'qrCodeUrl':
        'otpauth://totp/SecureMail:mohamed@securemail.com?secret=MOCK_SECRET&issuer=SecureMail',
    'secret': 'MOCK_SECRET_BASE32',
  };

  // ══════════════════════════════════════════════════════════
  // SESSIONS
  // ══════════════════════════════════════════════════════════

  /// GET /sessions
  static const mockSessions = [
    {
      'id': 1,
      'ipAddress': '192.168.1.1',
      'deviceOs': 'Android',
      'deviceBrowser': 'Chrome',
      'userAgent': 'Mozilla/5.0 (Android 14; Mobile)',
      'loginAt': '2024-03-15T08:30:00Z',
      'expiresAt': '2024-04-15T08:30:00Z',
      'isCurrent': true,
    },
    {
      'id': 2,
      'ipAddress': '102.45.23.11',
      'deviceOs': 'Windows',
      'deviceBrowser': 'Edge',
      'userAgent': 'Mozilla/5.0 (Windows NT 10.0; Win64)',
      'loginAt': '2024-03-10T14:20:00Z',
      'expiresAt': '2024-04-10T14:20:00Z',
      'isCurrent': false,
    },
    {
      'id': 3,
      'ipAddress': '197.32.14.55',
      'deviceOs': 'iOS',
      'deviceBrowser': 'Safari',
      'userAgent': 'Mozilla/5.0 (iPhone; CPU iPhone OS 17)',
      'loginAt': '2024-03-01T09:00:00Z',
      'expiresAt': '2024-04-01T09:00:00Z',
      'isCurrent': false,
    },
  ];

  // ══════════════════════════════════════════════════════════
  // MAILBOXES
  // ══════════════════════════════════════════════════════════

  /// GET /mailboxes
  static const mockMailboxes = [
    {
      'id': '1',
      'displayName': 'Personal Gmail',
      'email': 'mohamed@gmail.com',
      'provider': 'gmail',
      'pushNotificationsEnabled': true,
      'lastSyncAt': '2024-03-15T10:30:00Z',
      'createdAt': '2024-01-20T09:00:00Z',
      'unreadCount': 12,
    },
    {
      'id': '2',
      'displayName': 'Work Outlook',
      'email': 'mohamed@company.com',
      'provider': 'outlook',
      'pushNotificationsEnabled': true,
      'lastSyncAt': '2024-03-15T10:25:00Z',
      'createdAt': '2024-02-01T09:00:00Z',
      'unreadCount': 5,
    },
    {
      'id': '3',
      'displayName': 'Custom IMAP',
      'email': 'admin@mydomain.com',
      'provider': 'imap',
      'pushNotificationsEnabled': false,
      'lastSyncAt': '2024-03-15T09:00:00Z',
      'createdAt': '2024-02-15T09:00:00Z',
      'unreadCount': 0,
    },
  ];

  /// POST /mailboxes/imap
  /// Body: { host, port, email, password, secure, displayName, smtpHost?, smtpPort? }
  static const mockConnectImapResponse = {
    'message': 'IMAP mailbox connected successfully.',
    'mailbox': {
      'id': '4',
      'displayName': 'My Custom Mail',
      'email': 'user@mydomain.com',
      'provider': 'imap',
    },
  };

  // ══════════════════════════════════════════════════════════
  // EMAILS
  // ══════════════════════════════════════════════════════════

  /// GET /mailboxes/{mailboxId}/inbox
  static const mockInboxEmails = [
    {
      'id': 1,
      'mailboxId': 1,
      'subject': 'Q1 Security Report — Action Required',
      'from': 'security@company.com',
      'to': 'mohamed@gmail.com',
      'bodyText':
          'Please review the attached Q1 security report and take necessary action.',
      'bodyHtml': '<p>Please review the attached Q1 security report.</p>',
      'isRead': false,
      'classification': 'inbox',
      'securityVerdict': 'clean',
      'hasAttachments': true,
      'createdAt': '2024-03-15T09:30:00Z',
    },
    {
      'id': 2,
      'mailboxId': 1,
      'subject': 'Your password was changed',
      'from': 'noreply@google.com',
      'to': 'mohamed@gmail.com',
      'bodyText': 'Your Google account password was recently changed.',
      'bodyHtml': '<p>Your Google account password was recently changed.</p>',
      'isRead': true,
      'classification': 'inbox',
      'securityVerdict': 'clean',
      'hasAttachments': false,
      'createdAt': '2024-03-14T14:00:00Z',
    },
    {
      'id': 5,
      'mailboxId': 1,
      'subject': 'Meeting Tomorrow at 10 AM',
      'from': 'manager@company.com',
      'to': 'mohamed@gmail.com',
      'bodyText': 'Just a reminder about our team meeting tomorrow at 10 AM.',
      'bodyHtml': '<p>Just a reminder about our team meeting tomorrow.</p>',
      'isRead': true,
      'classification': 'inbox',
      'securityVerdict': 'clean',
      'hasAttachments': false,
      'createdAt': '2024-03-11T16:30:00Z',
    },
  ];

  /// GET /mailboxes/{mailboxId}/spam
  static const mockSpamEmails = [
    {
      'id': 4,
      'mailboxId': 1,
      'subject': 'You have won a prize!',
      'from': 'promo@spammy-deals.com',
      'to': 'mohamed@gmail.com',
      'bodyText':
          'Congratulations! You have been selected to win an amazing prize.',
      'isRead': false,
      'classification': 'spam',
      'securityVerdict': 'spam',
      'hasAttachments': false,
      'createdAt': '2024-03-12T08:00:00Z',
    },
  ];

  /// GET /mailboxes/{mailboxId}/phishing
  static const mockPhishingEmails = [
    {
      'id': 3,
      'mailboxId': 1,
      'subject': 'URGENT: Verify your account now!!!',
      'from': 'support@fake-bank-verify.com',
      'to': 'mohamed@gmail.com',
      'bodyText':
          'Click here to verify your account immediately or it will be suspended.',
      'isRead': false,
      'classification': 'phishing',
      'securityVerdict': 'phishing',
      'hasAttachments': false,
      'createdAt': '2024-03-13T11:00:00Z',
    },
  ];

  /// GET /mailboxes/{mailboxId}/sent
  static const mockSentEmails = [
    {
      'id': 6,
      'mailboxId': 1,
      'subject': 'Re: Q1 Security Report',
      'from': 'mohamed@gmail.com',
      'to': 'security@company.com',
      'bodyText': 'Thanks for the report. I will review it shortly.',
      'isRead': true,
      'classification': 'sent',
      'securityVerdict': 'clean',
      'hasAttachments': false,
      'createdAt': '2024-03-15T10:00:00Z',
    },
  ];

  // ══════════════════════════════════════════════════════════
  // ANALYTICS
  // ══════════════════════════════════════════════════════════

  /// GET /analytics/overview
  static const mockAnalyticsOverview = {
    'totalEmails': 1248,
    'threatsBlocked': 47,
    'phishingDetected': 23,
    'spamDetected': 18,
    'malwareDetected': 6,
    'cleanEmails': 1201,
    'systemHealth': 98,
    'criticalAlerts': 3,
  };

  /// GET /analytics/activity?period=weekly
  static const mockWeeklyActivity = [
    {'day': 'Mon', 'clean': 45, 'spam': 3, 'phishing': 1},
    {'day': 'Tue', 'clean': 62, 'spam': 5, 'phishing': 2},
    {'day': 'Wed', 'clean': 38, 'spam': 2, 'phishing': 0},
    {'day': 'Thu', 'clean': 71, 'spam': 7, 'phishing': 3},
    {'day': 'Fri', 'clean': 55, 'spam': 4, 'phishing': 1},
    {'day': 'Sat', 'clean': 20, 'spam': 1, 'phishing': 0},
    {'day': 'Sun', 'clean': 15, 'spam': 0, 'phishing': 0},
  ];

  // ══════════════════════════════════════════════════════════
  // NOTIFICATIONS / ALERTS
  // ══════════════════════════════════════════════════════════

  /// GET /notifications
  static const mockNotifications = [
    {
      'id': 1,
      'title': 'Phishing Email Detected',
      'message': 'A phishing email was detected in your Gmail mailbox.',
      'type': 'PHISHING_DETECTED',
      'isRead': false,
      'createdAt': '2024-03-15T10:00:00Z',
    },
    {
      'id': 2,
      'title': 'New Login Detected',
      'message': 'A new login was detected from Windows — Edge browser.',
      'type': 'NEW_LOGIN_DETECTED',
      'isRead': false,
      'createdAt': '2024-03-14T08:30:00Z',
    },
    {
      'id': 3,
      'title': 'Weekly Security Report',
      'message':
          'Your weekly security report is ready. 47 threats were blocked.',
      'type': 'WEEKLY_SECURITY_REPORT',
      'isRead': true,
      'createdAt': '2024-03-10T09:00:00Z',
    },
    {
      'id': 4,
      'title': 'Malware Detected',
      'message': 'A malware attachment was detected and quarantined.',
      'type': 'MALWARE_DETECTED',
      'isRead': true,
      'createdAt': '2024-03-08T14:00:00Z',
    },
    {
      'id': 5,
      'title': 'Password Changed',
      'message': 'Your SecureMail password was changed successfully.',
      'type': 'PASSWORD_CHANGED',
      'isRead': true,
      'createdAt': '2024-03-01T11:00:00Z',
    },
  ];
  // ══════════════════════════════════════════════════════════
  // INCIDENTS
  // ══════════════════════════════════════════════════════════

  /// GET /incidents
  static const mockIncidents = [
    {
      'id': 'inc_001',
      'type': 'criticalThreat',
      'title': 'Phishing Attempt: IT Support',
      'description': 'Targeting: CEO Office • Source: external-mail.net',
      'timeAgo': '2m ago',
      'avatarInitials': ['JD', 'AS'],
    },
    {
      'id': 'inc_002',
      'type': 'suspiciousActivity',
      'title': 'Bulk Data Export Request',
      'description': 'Origin: Unusual IP (Shanghai) • Volume: 4.2GB',
      'timeAgo': '45m ago',
      'location': 'Shanghai, CN',
    },
    {
      'id': 'inc_003',
      'type': 'systemUpdate',
      'title': 'Firewall Rules Updated',
      'description': 'Auto-remediation successful for port 8080',
      'timeAgo': '2h ago',
      'resolvedLabel': 'Resolved Automatically',
      'isRead': true,
    },
  ];

  // ══════════════════════════════════════════════════════════
  // HELPERS
  // ══════════════════════════════════════════════════════════

  /// Simulate network delay
  static Future<T> simulate<T>(T data, {int milliseconds = 800}) async {
    await Future.delayed(Duration(milliseconds: milliseconds));
    return data;
  }

  /// Simulate auth call
  static Future<bool> simulateAuth({bool success = true}) async {
    await Future.delayed(const Duration(milliseconds: 1200));
    return success;
  }
}
