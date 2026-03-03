import '../../../core/network/api_client.dart';

class TicketsApi {
  TicketsApi(this._client);

  final ApiClient _client;

  Future<dynamic> getMyTickets() {
    return _client.get<dynamic>('/tickets/me/EVENT');
  }

  Future<Map<String, dynamic>> validateTicket({required String qr}) {
    return _client.post<Map<String, dynamic>>(
      '/tickets/validate',
      data: <String, dynamic>{'qr': qr},
    );
  }

  Future<Map<String, dynamic>> checkIn({required String bookingId}) {
    return _client.post<Map<String, dynamic>>(
      '/tickets/check-in',
      data: <String, dynamic>{'bookingId': bookingId},
    );
  }
}
