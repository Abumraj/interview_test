import '../../../core/network/api_client.dart';

class NotificationsApi {
  NotificationsApi(this._client);

  final ApiClient _client;

  Future<Map<String, dynamic>> registerToken({
    required String token,
    required String deviceType,
  }) {
    return _client.post<Map<String, dynamic>>(
      '/notifications/register-token',
      data: <String, dynamic>{
        'token': token,
        'deviceType': deviceType,
      },
    );
  }

  Future<Map<String, dynamic>> unregisterToken({
    required String token,
  }) {
    return _client.delete<Map<String, dynamic>>(
      '/notifications/unregister-token',
      data: <String, dynamic>{
        'token': token,
      },
    );
  }

  Future<List<dynamic>> getMyNotifications() async {
    final result = await _client.get<dynamic>('/notifications/my-notifications');
    if (result is List) return result;
    if (result is Map<String, dynamic>) {
      final data = result['data'];
      if (data is List) return data;
    }
    return <dynamic>[];
  }

  Future<Map<String, dynamic>> markAsRead({required String notificationId}) {
    return _client.patch<Map<String, dynamic>>(
      '/notifications/$notificationId/read',
    );
  }

  Future<Map<String, dynamic>> getUnreadCount() {
    return _client.get<Map<String, dynamic>>('/notifications/unread-count');
  }
}
