import '../domain/booking.dart';
import '../domain/booked_item.dart';
import 'bookings_api.dart';

class BookingsRepository {
  BookingsRepository({required BookingsApi api}) : _api = api;

  final BookingsApi _api;

  Booking? _parseBooking(Object? json) {
    Object? raw = json;
    if (raw is Map<String, dynamic>) {
      raw = raw['data'] ?? raw['booking'] ?? raw['result'] ?? raw;
    }

    if (raw is Map<String, dynamic>) {
      return Booking.fromJson(raw);
    }

    return null;
  }

  Future<Booking?> createBooking({
    required String userId,
    required String startTime,
    required String pricingId,
    String? paymentId,
    required num totalPrice,
    required num duration,
    Map<String, dynamic>? meta,
    String status = 'PENDING',
  }) async {
    final json = await _api.createBooking(
      userId: userId,
      startTime: startTime,
      pricingId: pricingId,
      paymentId: paymentId,
      totalPrice: totalPrice,
      duration: duration,
      meta: meta,
      status: status,
    );
    return _parseBooking(json);
  }

  Future<Booking?> createEventBooking({
    required String userId,
    required String slotId,
    String? paymentId,
    required num totalPrice,
    Map<String, dynamic>? meta,
    String status = 'PENDING',
  }) async {
    final json = await _api.createEventBooking(
      userId: userId,
      slotId: slotId,
      paymentId: paymentId,
      totalPrice: totalPrice,
      meta: meta,
      status: status,
    );
    return _parseBooking(json);
  }

  Future<void> cancelBooking({required String bookingId}) async {
    await _api.cancelBooking(bookingId: bookingId);
  }

  List<BookedItem> _parseBookedItems(Object? json) {
    Object? raw = json;
    for (var i = 0; i < 3; i++) {
      if (raw is List) break;
      if (raw is Map<String, dynamic>) {
        raw = raw['data'] ?? raw['items'] ?? raw['results'] ?? raw;
        continue;
      }
      if (raw is Map) {
        final m = Map<String, dynamic>.from(raw);
        raw = m['data'] ?? m['items'] ?? m['results'] ?? raw;
        continue;
      }
      break;
    }

    if (raw is List) {
      return raw
          .whereType<Map>()
          .map((e) => BookedItem.fromJson(Map<String, dynamic>.from(e)))
          .toList(growable: false);
    }

    return const <BookedItem>[];
  }

  Future<List<BookedItem>> getBookedItems({required String paymentId}) async {
    final json = await _api.getBookedItems(paymentId: paymentId);
    return _parseBookedItems(json);
  }
}
