import 'package:securemail/core/network/api_client.dart';
import 'package:securemail/core/constants/ApiConstants.dart';
import '../models/notification_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

abstract class IAlertsRepository {
  Future<List<NotificationModel>> getAlerts({int page = 1, int limit = 50});
  Future<int> getUnreadCount();
  Future<void> markAsRead(int id);
  Future<void> markAllAsRead();
  Future<void> deleteAlert(int id);
}

class AlertsRepository implements IAlertsRepository {
  @override
  Future<List<NotificationModel>> getAlerts({int page = 1, int limit = 50}) async {
    final response = await ApiClient.get(
      ApiConstants.notifications,
      queryParameters: {'page': page, 'limit': limit},
    );
    final dynamic responseData = response.data['data'];
    final List<dynamic> data = responseData is List ? responseData : responseData['data'];
    return data.map((n) => NotificationModel.fromJson(n)).toList();
  }

  @override
  Future<int> getUnreadCount() async {
    final response = await ApiClient.get(ApiConstants.notificationsUnreadCount);
    return response.data['data'] as int? ?? 0;
  }

  @override
  Future<void> markAsRead(int id) async {
    await ApiClient.patch(ApiConstants.notificationMarkRead(id));
  }

  @override
  Future<void> markAllAsRead() async {
    await ApiClient.patch(ApiConstants.notificationsReadAll);
  }

  @override
  Future<void> deleteAlert(int id) async {
    await ApiClient.delete(ApiConstants.notificationById(id));
  }
}

final alertsRepositoryProvider = Provider<IAlertsRepository>((ref) {
  return AlertsRepository();
});
