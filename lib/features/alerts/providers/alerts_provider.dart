import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/alert_model.dart';
import '../repositories/alerts_repository.dart';

final alertsProvider = StateNotifierProvider<AlertsNotifier, AlertsState>((ref) {
  final repository = ref.watch(alertsRepositoryProvider);
  return AlertsNotifier(repository);
});

class AlertsState {
  final bool isLoading;
  final List<AlertNotification> allAlerts;
  final AlertCategory selectedCategory;
  final String? error;

  AlertsState({
    this.isLoading = false,
    this.allAlerts = const [],
    this.selectedCategory = AlertCategory.all,
    this.error,
  });

  List<AlertNotification> get filteredAlerts {
    if (selectedCategory == AlertCategory.all) return allAlerts;
    return allAlerts.where((a) => a.category == selectedCategory).toList();
  }

  int get criticalCount => allAlerts.where((a) => a.severity == AlertSeverity.critical).length;

  AlertsState copyWith({
    bool? isLoading,
    List<AlertNotification>? allAlerts,
    AlertCategory? selectedCategory,
    String? error,
  }) {
    return AlertsState(
      isLoading: isLoading ?? this.isLoading,
      allAlerts: allAlerts ?? this.allAlerts,
      selectedCategory: selectedCategory ?? this.selectedCategory,
      error: error ?? this.error,
    );
  }
}

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
      final alerts = await _repository.getAlerts();
      state = state.copyWith(isLoading: false, allAlerts: alerts);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  void markAsRead(String id) {
    final updated = state.allAlerts.map((a) {
      if (a.id == id) return AlertNotification(
        id: a.id, title: a.title, description: a.description, timestamp: a.timestamp, 
        category: a.category, severity: a.severity, isRead: true, icon: a.icon, actions: a.actions
      );
      return a;
    }).toList();
    state = state.copyWith(allAlerts: updated);
  }
}
