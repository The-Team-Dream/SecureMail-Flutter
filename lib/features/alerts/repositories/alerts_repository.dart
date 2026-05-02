import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/alert_model.dart';

abstract class IAlertsRepository {
  Future<List<AlertNotification>> getAlerts();
}

class AlertsRepository implements IAlertsRepository {
  @override
  Future<List<AlertNotification>> getAlerts() async {
    // Simulate API Delay
    await Future.delayed(const Duration(milliseconds: 800));

    // Mock Data (Moved from provider)
    return [
      AlertNotification(
        id: '1',
        title: 'Suspicious Login Blocked',
        description: 'Attempted access from Moscow, RU (IP: 95.161.22.10) using your primary credentials.',
        timestamp: DateTime.now().subtract(const Duration(minutes: 2)),
        category: AlertCategory.threats,
        severity: AlertSeverity.critical,
        icon: Icons.security_outlined,
        isRead: false,
        actions: ['Change Password', 'Dismiss'],
      ),
      AlertNotification(
        id: '2',
        title: 'New Device Linked',
        description: 'MacBook Pro 16" was added to your trusted devices list via 2FA verification.',
        timestamp: DateTime.now().subtract(const Duration(minutes: 45)),
        category: AlertCategory.threats,
        severity: AlertSeverity.high,
        icon: Icons.devices_outlined,
        isRead: false,
      ),
      AlertNotification(
        id: '3',
        title: 'v4.2.0 Security Patch',
        description: 'Enhanced encryption protocols for IMAP/SMTP connections are now active.',
        timestamp: DateTime.now().subtract(const Duration(days: 1)),
        category: AlertCategory.updates,
        severity: AlertSeverity.info,
        icon: Icons.system_update_alt_outlined,
        isRead: true,
      ),
      AlertNotification(
        id: '4',
        title: 'Backup Successful',
        description: 'All encrypted mailboxes successfully backed up to SecureCloud Node-7.',
        timestamp: DateTime.now().subtract(const Duration(days: 2)),
        category: AlertCategory.system,
        severity: AlertSeverity.info,
        icon: Icons.cloud_done_outlined,
        isRead: true,
      ),
    ];
  }
}

final alertsRepositoryProvider = Provider<IAlertsRepository>((ref) {
  return AlertsRepository();
});
