import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/analytics_model.dart';
import '../repositories/analytics_repository.dart';

final analyticsProvider = StateNotifierProvider<AnalyticsNotifier, AnalyticsState>((ref) {
  final repository = ref.watch(analyticsRepositoryProvider);
  return AnalyticsNotifier(repository);
});

class AnalyticsState {
  final bool isLoading;
  final AnalyticsData? data;
  final String? error;

  AnalyticsState({
    this.isLoading = false,
    this.data,
    this.error,
  });

  AnalyticsState copyWith({
    bool? isLoading,
    AnalyticsData? data,
    String? error,
  }) {
    return AnalyticsState(
      isLoading: isLoading ?? this.isLoading,
      data: data ?? this.data,
      error: error ?? this.error,
    );
  }
}

class AnalyticsNotifier extends StateNotifier<AnalyticsState> {
  final IAnalyticsRepository _repository;

  AnalyticsNotifier(this._repository) : super(AnalyticsState()) {
    fetchAnalytics();
  }

  Future<void> fetchAnalytics() async {
    state = state.copyWith(isLoading: true);
    try {
      final data = await _repository.getAnalytics();
      state = state.copyWith(isLoading: false, data: data);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }
}
