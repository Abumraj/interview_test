import '../../../models/notification.dart';
import 'notifications_api.dart';

class NotificationsRepository {
  NotificationsRepository({required NotificationsApi api}) : _api = api;

  final NotificationsApi _api;

  Future<void> registerToken({
    required String token,
    required String deviceType,
  }) async {
    await _api.registerToken(token: token, deviceType: deviceType);
  }

  Future<void> unregisterToken({required String token}) async {
    await _api.unregisterToken(token: token);
  }

  Future<List<NotificationData>> getMyNotifications() async {
    final raw = await _api.getMyNotifications();
    return raw
        .whereType<Map>()
        .map((e) => NotificationData.fromJson(Map<String, dynamic>.from(e)))
        .toList(growable: false);
  }

  Future<void> markAsRead({required String notificationId}) async {
    await _api.markAsRead(notificationId: notificationId);
  }

  Future<int> getUnreadCount() async {
    final json = await _api.getUnreadCount();
    final count = json['unreadCount'];
    if (count is int) return count;
    if (count is num) return count.toInt();
    return int.tryParse(count?.toString() ?? '') ?? 0;
  }
}
