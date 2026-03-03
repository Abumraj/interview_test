import '../../../core/network/api_client.dart';

class HistoryApi {
  HistoryApi(this._client);

  final ApiClient _client;

  Future<dynamic> getMyPurchases(userId) {
    return _client.get<dynamic>('/purchases-history/$userId');
  }

  Future<Map<String, dynamic>> getPurchaseDetails(String bookingId) {
    return _client.get<Map<String, dynamic>>(
      '/purchases-history/single/$bookingId',
    );
  }
}
