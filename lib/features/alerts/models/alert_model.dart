import 'package:flutter/material.dart';

enum AlertCategory { all, threats, updates, system }

enum AlertSeverity { critical, high, medium, info }

class AlertNotification {
  final String id;
  final String title;
  final String description;
  final DateTime timestamp;
  final AlertCategory category;
  final AlertSeverity severity;
  final bool isRead;
  final IconData icon;
  final List<String>? actions;

  AlertNotification({
    required this.id,
    required this.title,
    required this.description,
    required this.timestamp,
    required this.category,
    required this.severity,
    this.isRead = false,
    required this.icon,
    this.actions,
  });

  // Factory for API integration
  factory AlertNotification.fromJson(Map<String, dynamic> json) {
    return AlertNotification(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      timestamp: DateTime.parse(json['timestamp'] ?? DateTime.now().toString()),
      category: _parseCategory(json['category']),
      severity: _parseSeverity(json['severity']),
      isRead: json['isRead'] ?? false,
      icon: _parseIcon(json['icon']),
      actions: (json['actions'] as List?)?.map((e) => e.toString()).toList(),
    );
  }

  static AlertCategory _parseCategory(String? cat) {
    switch (cat?.toLowerCase()) {
      case 'threats':
        return AlertCategory.threats;
      case 'updates':
        return AlertCategory.updates;
      case 'system':
        return AlertCategory.system;
      default:
        return AlertCategory.all;
    }
  }

  static AlertSeverity _parseSeverity(String? sev) {
    switch (sev?.toLowerCase()) {
      case 'critical':
        return AlertSeverity.critical;
      case 'high':
        return AlertSeverity.high;
      case 'medium':
        return AlertSeverity.medium;
      default:
        return AlertSeverity.info;
    }
  }

  static IconData _parseIcon(String? icon) {
    switch (icon) {
      case 'security':
        return Icons.security_outlined;
      case 'device':
        return Icons.devices_outlined;
      case 'update':
        return Icons.system_update_alt_outlined;
      case 'backup':
        return Icons.cloud_done_outlined;
      default:
        return Icons.notifications_none_outlined;
    }
  }
}
