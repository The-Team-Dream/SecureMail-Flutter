import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/analytics_model.dart';
import '../repositories/analytics_repository.dart';
import 'package:securemail/features/auth/providers/auth_provider.dart';

final analyticsOverviewProvider = FutureProvider<AnalyticsOverviewModel>((ref) async {
  ref.watch(authProvider.select((s) => s.isAuthenticated));
  final repository = ref.watch(analyticsRepositoryProvider);
  return repository.getOverview();
});

final analyticsActivityProvider = FutureProvider.family<List<ActivityDataPoint>, String>((ref, period) async {
  final repository = ref.watch(analyticsRepositoryProvider);
  return repository.getActivity(period: period);
});
