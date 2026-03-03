import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/api_client.dart';
import '../../../core/network/core_network_providers.dart';
import '../data/bookings_api.dart';
import '../data/bookings_repository.dart';
import '../domain/booking.dart';
import '../domain/booked_item.dart';

final bookingsRepositoryProvider = Provider<BookingsRepository>((ref) {
  final ApiClient client = ref.watch(apiClientProvider);
  return BookingsRepository(api: BookingsApi(client));
});

final bookingsControllerProvider =
    AsyncNotifierProvider<BookingsController, void>(BookingsController.new);

final cartCountProvider = StateProvider<int>((ref) => 0);

final bookedItemsProvider = FutureProvider.family<List<BookedItem>, String>((
  ref,
  paymentId,
) async {
  final repo = ref.read(bookingsRepositoryProvider);
  return repo.getBookedItems(paymentId: paymentId);
});

class BookingsController extends AsyncNotifier<void> {
  @override
  Future<void> build() async {}

  Future<Booking?> book({
    required String userId,
    required String startTime,
    required String pricingId,
    String? paymentId,
    required num totalPrice,
    required num duration,
    Map<String, dynamic>? meta,
  }) async {
    state = const AsyncLoading();
    try {
      final repo = ref.read(bookingsRepositoryProvider);
      final booking = await repo.createBooking(
        userId: userId,
        startTime: startTime,
        pricingId: pricingId,
        paymentId: paymentId,
        totalPrice: totalPrice,
        duration: duration,
        meta: meta,
      );
      state = const AsyncData(null);
      return booking;
    } catch (e, st) {
      state = AsyncError(e, st);
      rethrow;
    }
  }

  Future<Booking?> bookEvent({
    required String userId,
    required String slotId,
    String? paymentId,
    required num totalPrice,
    Map<String, dynamic>? meta,
  }) async {
    state = const AsyncLoading();
    try {
      final repo = ref.read(bookingsRepositoryProvider);
      final booking = await repo.createEventBooking(
        userId: userId,
        slotId: slotId,
        paymentId: paymentId,
        totalPrice: totalPrice,
        meta: meta,
      );
      state = const AsyncData(null);
      return booking;
    } catch (e, st) {
      state = AsyncError(e, st);
      rethrow;
    }
  }
}
