import 'package:securemail/core/network/api_client.dart';
import 'package:securemail/core/constants/ApiConstants.dart';
import '../models/analytics_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

abstract class IAnalyticsRepository {
  Future<AnalyticsOverviewModel> getOverview();
  Future<List<ActivityDataPoint>> getActivity({String period = 'weekly'});
}

class AnalyticsRepository implements IAnalyticsRepository {
  @override
  Future<AnalyticsOverviewModel> getOverview() async {
    final response = await ApiClient.get(ApiConstants.analyticsOverview);
    return AnalyticsOverviewModel.fromJson(response.data);
  }

  @override
  Future<List<ActivityDataPoint>> getActivity({String period = 'weekly'}) async {
    final response = await ApiClient.get(
      ApiConstants.analyticsActivity,
      queryParameters: {'period': period},
    );
    final List<dynamic> data = response.data['data'];
    return data.map((p) => ActivityDataPoint.fromJson(p)).toList();
  }
}

final analyticsRepositoryProvider = Provider<IAnalyticsRepository>((ref) {
  return AnalyticsRepository();
});
