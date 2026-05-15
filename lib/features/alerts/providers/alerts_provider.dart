import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:securemail/features/auth/providers/auth_provider.dart';
import '../models/alert_model.dart';
import '../repositories/alerts_repository.dart';
import 'package:securemail/features/auth/providers/auth_provider.dart';
import 'package:securemail/core/network/socket_service.dart';
import 'dart:async';

// ── State ──────────────────────────────────────────────────

class AlertsState {
  final bool isLoading;
  final List<AlertNotification> notifications;
  final String? error;
  final AlertCategory selectedCategory;

  AlertsState({
    this.isLoading = false,
    this.notifications = const [],
    this.error,
    this.selectedCategory = AlertCategory.all,
  });

  // ── Getters للواجهة (مطابقة لـ AlertsScreen.dart) ─────────

  /// حساب التنبيهات الحرجة
  int get criticalCount => notifications
      .where((n) =>
          n.severity == AlertSeverity.critical ||
          n.severity == AlertSeverity.high)
      .length;

  /// تصفية التنبيهات بناءً على التصنيف المختار (state.filteredAlerts)
  List<AlertNotification> get filteredAlerts {
    if (selectedCategory == AlertCategory.all) return notifications;
    return notifications.where((n) => n.category == selectedCategory).toList();
  }

  AlertsState copyWith({
    bool? isLoading,
    List<AlertNotification>? notifications,
    String? error,
    AlertCategory? selectedCategory,
  }) {
    return AlertsState(
      isLoading: isLoading ?? this.isLoading,
      notifications: notifications ?? this.notifications,
      error: error ?? this.error,
      selectedCategory: selectedCategory ?? this.selectedCategory,
    );
  }
}

// ── Notifier ───────────────────────────────────────────────

class AlertsNotifier extends StateNotifier<AlertsState> {
  final IAlertsRepository _repository;

  AlertsNotifier(this._repository) : super(AlertsState()) {
    fetchAlerts();
    _listenToSocket();
  }

  StreamSubscription? _socketSub;

  void _listenToSocket() {
    _socketSub?.cancel();
    _socketSub = socketService.notificationsStream.listen((data) {
      // Refresh list when a new notification arrives via socket
      fetchAlerts();
    });
  }

  @override
  void dispose() {
    _socketSub?.cancel();
    super.dispose();
  }

  void setCategory(AlertCategory category) {
    state = state.copyWith(selectedCategory: category);
  }

  Future<void> fetchAlerts() async {
    state = state.copyWith(isLoading: true);
    try {
      // جلب البيانات من المستودع (Repository)
      final rawNotifications = await _repository.getAlerts();

      // تحويل البيانات الخام إلى AlertNotification (إذا لزم الأمر)
      // ملاحظة: الـ Repository حالياً يعيد NotificationModel، سنقوم بتحويله هنا
      final alerts = rawNotifications
          .map((n) => AlertNotification(
                id: n.id.toString(),
                title: n.title,
                description: n.message,
                timestamp: DateTime.parse(n.createdAt),
                category: _mapTypeToCategory(n.type),
                severity: _mapTypeToSeverity(n.type),
                icon: _mapTypeToIcon(n.type),
                isRead: n.isRead,
                mailBoxId: n.mailBoxId,
                emailId: n.emailId,
              ))
          .toList();

      state = state.copyWith(isLoading: false, notifications: alerts);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  // ── Helpers للمسح (Mapping) ───────────────────────────────

  AlertCategory _mapTypeToCategory(String type) {
    switch (type) {
      case 'PHISHING_DETECTED':
      case 'MALWARE_DETECTED':
        return AlertCategory.threats;
      case 'PASSWORD_CHANGED':
      case 'NEW_LOGIN_DETECTED':
      case 'FAILED_SYNC':
        return AlertCategory.system;
      case 'LOW_MAILBOX_SPACE':
      case 'WEEKLY_SECURITY_REPORT':
      case 'NEW_EMAIL_RECEIVED':
        return AlertCategory.updates;
      default:
        return AlertCategory.updates;
    }
  }

  AlertSeverity _mapTypeToSeverity(String type) {
    switch (type) {
      case 'PHISHING_DETECTED':
      case 'MALWARE_DETECTED':
        return AlertSeverity.critical;
      case 'PASSWORD_CHANGED':
      case 'NEW_LOGIN_DETECTED':
        return AlertSeverity.high;
      case 'FAILED_SYNC':
      case 'LOW_MAILBOX_SPACE':
        return AlertSeverity.medium;
      default:
        return AlertSeverity.info;
    }
  }

  IconData _mapTypeToIcon(String type) {
    switch (type) {
      case 'PHISHING_DETECTED':
      case 'MALWARE_DETECTED':
        return Icons.gpp_bad_outlined;
      case 'PASSWORD_CHANGED':
        return Icons.lock_reset_outlined;
      case 'NEW_LOGIN_DETECTED':
        return Icons.devices_outlined;
      case 'FAILED_SYNC':
        return Icons.sync_problem_outlined;
      case 'LOW_MAILBOX_SPACE':
        return Icons.storage_outlined;
      case 'WEEKLY_SECURITY_REPORT':
        return Icons.assessment_outlined;
      case 'NEW_EMAIL_RECEIVED':
        return Icons.mail_outline;
      default:
        return Icons.notifications_none_outlined;
    }
  }

  // ── Actions ───────────────────────────────────────────────

  Future<void> markAsRead(int id) async {
    try {
      await _repository.markAsRead(id);
      fetchAlerts(); // تحديث القائمة
    } catch (_) {}
  }

  Future<void> markAllAsRead() async {
    try {
      await _repository.markAllAsRead();
      fetchAlerts(); // تحديث القائمة
    } catch (_) {}
  }

  Future<void> deleteAlert(int id) async {
    try {
      await _repository.deleteAlert(id);
      fetchAlerts(); // تحديث القائمة
    } catch (_) {}
  }
}

// ── Providers ─────────────────────────────────────────────

final alertsProvider =
    StateNotifierProvider<AlertsNotifier, AlertsState>((ref) {
  ref.watch(authProvider.select((s) => s.isAuthenticated));
  final repository = ref.watch(alertsRepositoryProvider);
  return AlertsNotifier(repository);
});

final unreadCountProvider = FutureProvider<int>((ref) async {
  final repository = ref.watch(alertsRepositoryProvider);
  return repository.getUnreadCount();
});
