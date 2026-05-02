import '../models/analytics_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

abstract class IAnalyticsRepository {
  Future<AnalyticsData> getAnalytics();
}

class AnalyticsRepository implements IAnalyticsRepository {
  @override
  Future<AnalyticsData> getAnalytics() async {
    // Simulate API Delay
    await Future.delayed(const Duration(seconds: 1));

    // Mock Data (Moved from provider to repository)
    return AnalyticsData(
      totalThreatsBlocked: 12482,
      threatsChangePercentage: 14.0,
      criticalAlerts: 3,
      alertsChangePercentage: -82.0,
      systemHealth: 99.9,
      healthStatus: 'Stable',
      weeklyDistribution: [
        ThreatDistribution(day: 'MON', value: 120),
        ThreatDistribution(day: 'TUE', value: 150),
        ThreatDistribution(day: 'WED', value: 100),
        ThreatDistribution(day: 'THU', value: 180),
        ThreatDistribution(day: 'FRI', value: 200),
        ThreatDistribution(day: 'SAT', value: 80),
        ThreatDistribution(day: 'SUN', value: 60),
      ],
      recentEvents: [
        SecurityEvent(
          id: '1',
          title: 'Unauthorized Access Attempt',
          description: 'IP: 192.168.1.254 • Location: Unknown',
          timestamp: DateTime.now().subtract(const Duration(minutes: 2)),
          severity: EventSeverity.high,
          icon: Icons.error_outline_rounded,
        ),
        SecurityEvent(
          id: '2',
          title: 'SSL Certificate Renewed',
          description: 'Domain: secure.mail-service.io',
          timestamp: DateTime.now().subtract(const Duration(hours: 1)),
          severity: EventSeverity.info,
          icon: Icons.check_circle_outline_rounded,
        ),
        SecurityEvent(
          id: '3',
          title: 'Policy Update Detected',
          description: 'Filter: Restricted Attachments',
          timestamp: DateTime.now().subtract(const Duration(hours: 3)),
          severity: EventSeverity.medium,
          icon: Icons.security_outlined,
        ),
      ],
    );
  }
}

// Provider for the repository

final analyticsRepositoryProvider = Provider<IAnalyticsRepository>((ref) {
  return AnalyticsRepository();
});
