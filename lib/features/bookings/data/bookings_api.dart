import '../../../core/network/api_client.dart';

class BookingsApi {
  BookingsApi(this._client);

  final ApiClient _client;

  Future<Map<String, dynamic>> createBooking({
    required String userId,
    required String startTime,
    required String pricingId,
    String? paymentId,
    required num totalPrice,
    required num duration,
    required Map<String, dynamic>? meta,
    required String status,
  }) {
    return _client.post<Map<String, dynamic>>(
      '/bookings/product',
      data: <String, dynamic>{
        if (paymentId != null && paymentId.isNotEmpty) 'paymentId': paymentId,
        'userId': userId,
        'startTime': startTime,
        'pricingId': pricingId,
        'totalPrice': totalPrice,
        'duration': duration,
        'meta': meta,
        // 'status': status,
      },
    );
  }

  Future<Map<String, dynamic>> createEventBooking({
    required String userId,
    required String slotId,
    String? paymentId,
    required num totalPrice,
    required Map<String, dynamic>? meta,
    required String status,
  }) {
    return _client.post<Map<String, dynamic>>(
      '/bookings/event',
      data: <String, dynamic>{
        if (paymentId != null && paymentId.isNotEmpty) 'paymentId': paymentId,
        'userId': userId,
        'slotId': slotId,
        'totalPrice': totalPrice,
        'meta': meta,
        'status': status,
      },
    );
  }

  Future<Map<String, dynamic>> cancelBooking({String? bookingId}) {
    return _client.patch<Map<String, dynamic>>(
      '/bookings',
      data:
          bookingId == null ? null : <String, dynamic>{'bookingId': bookingId},
    );
  }

  Future<Map<String, dynamic>> getBookedItems({required String paymentId}) {
    return _client.get<Map<String, dynamic>>(
      '/bookings/booked-items/$paymentId',
    );
  }
}
