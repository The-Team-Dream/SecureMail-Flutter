import 'package:flutter/material.dart';

class AnalyticsData {
  final int totalThreatsBlocked;
  final double threatsChangePercentage;
  final int criticalAlerts;
  final double alertsChangePercentage;
  final double systemHealth;
  final String healthStatus;
  final List<ThreatDistribution> weeklyDistribution;
  final List<SecurityEvent> recentEvents;

  AnalyticsData({
    required this.totalThreatsBlocked,
    required this.threatsChangePercentage,
    required this.criticalAlerts,
    required this.alertsChangePercentage,
    required this.systemHealth,
    required this.healthStatus,
    required this.weeklyDistribution,
    required this.recentEvents,
  });

  // For Future Backend Integration
  factory AnalyticsData.fromJson(Map<String, dynamic> json) {
    return AnalyticsData(
      totalThreatsBlocked: json['totalThreatsBlocked'] ?? 0,
      threatsChangePercentage: (json['threatsChangePercentage'] ?? 0).toDouble(),
      criticalAlerts: json['criticalAlerts'] ?? 0,
      alertsChangePercentage: (json['alertsChangePercentage'] ?? 0).toDouble(),
      systemHealth: (json['systemHealth'] ?? 0).toDouble(),
      healthStatus: json['healthStatus'] ?? 'Unknown',
      weeklyDistribution: (json['weeklyDistribution'] as List?)
              ?.map((e) => ThreatDistribution.fromJson(e))
              .toList() ??
          [],
      recentEvents: (json['recentEvents'] as List?)
              ?.map((e) => SecurityEvent.fromJson(e))
              .toList() ??
          [],
    );
  }
}

class ThreatDistribution {
  final String day;
  final int value;

  ThreatDistribution({required this.day, required this.value});

  factory ThreatDistribution.fromJson(Map<String, dynamic> json) {
    return ThreatDistribution(
      day: json['day'] ?? '',
      value: json['value'] ?? 0,
    );
  }
}

enum EventSeverity { low, medium, high, info }

class SecurityEvent {
  final String id;
  final String title;
  final String description;
  final DateTime timestamp;
  final EventSeverity severity;
  final IconData icon;

  SecurityEvent({
    required this.id,
    required this.title,
    required this.description,
    required this.timestamp,
    required this.severity,
    required this.icon,
  });

  factory SecurityEvent.fromJson(Map<String, dynamic> json) {
    return SecurityEvent(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      timestamp: DateTime.parse(json['timestamp'] ?? DateTime.now().toString()),
      severity: _parseSeverity(json['severity']),
      icon: _parseIcon(json['icon']),
    );
  }

  static EventSeverity _parseSeverity(String? severity) {
    switch (severity?.toLowerCase()) {
      case 'high':
        return EventSeverity.high;
      case 'medium':
        return EventSeverity.medium;
      case 'low':
        return EventSeverity.low;
      default:
        return EventSeverity.info;
    }
  }

  static IconData _parseIcon(String? icon) {
    switch (icon) {
      case 'warning':
        return Icons.warning_amber_rounded;
      case 'security':
        return Icons.security_rounded;
      default:
        return Icons.info_outline;
    }
  }
}
