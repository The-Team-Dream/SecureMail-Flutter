import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/alert_model.dart';
import '../repositories/alerts_repository.dart';

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
  int get criticalCount => notifications.where((n) => 
    n.severity == AlertSeverity.critical || n.severity == AlertSeverity.high
  ).length;

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
      isLoading:        isLoading        ?? this.isLoading,
      notifications:    notifications    ?? this.notifications,
      error:            error            ?? this.error,
      selectedCategory: selectedCategory ?? this.selectedCategory,
    );
  }
}

// ── Notifier ───────────────────────────────────────────────

class AlertsNotifier extends StateNotifier<AlertsState> {
  final IAlertsRepository _repository;

  AlertsNotifier(this._repository) : super(AlertsState()) {
    fetchAlerts();
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
      final alerts = rawNotifications.map((n) => AlertNotification(
        id:          n.id.toString(),
        title:       n.title,
        description: n.message,
        timestamp:   DateTime.parse(n.createdAt),
        category:    _mapTypeToCategory(n.type),
        severity:    _mapTypeToSeverity(n.type),
        icon:        _mapTypeToIcon(n.type),
        isRead:      n.isRead,
      )).toList();

      state = state.copyWith(isLoading: false, notifications: alerts);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  // ── Helpers للمسح (Mapping) ───────────────────────────────

  AlertCategory _mapTypeToCategory(String type) {
    if (type == 'PHISHING' || type == 'MALWARE' || type == 'THREAT') return AlertCategory.threats;
    if (type == 'SYSTEM') return AlertCategory.system;
    return AlertCategory.updates;
  }

  AlertSeverity _mapTypeToSeverity(String type) {
    if (type == 'PHISHING' || type == 'MALWARE') return AlertSeverity.critical;
    if (type == 'THREAT') return AlertSeverity.high;
    return AlertSeverity.info;
  }

  dynamic _mapTypeToIcon(String type) {
    // سيتم استخدام الـ IconData المناسب بناءً على النوع
    return AlertNotification.fromJson({}).icon; // استخدام القيمة الافتراضية مؤقتاً
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

final alertsProvider = StateNotifierProvider<AlertsNotifier, AlertsState>((ref) {
  final repository = ref.watch(alertsRepositoryProvider);
  return AlertsNotifier(repository);
});

final unreadCountProvider = FutureProvider<int>((ref) async {
  final repository = ref.watch(alertsRepositoryProvider);
  return repository.getUnreadCount();
});
