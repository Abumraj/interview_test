import '../../../core/network/api_client.dart';

class PointsApi {
  PointsApi(this._client);

  final ApiClient _client;

  Future<Map<String, dynamic>> getBalance() {
    return _client.get<Map<String, dynamic>>('/points');
  }

  Future<Map<String, dynamic>> getHistory() {
    return _client.get<Map<String, dynamic>>('/points/history');
  }
}
