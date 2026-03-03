import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/api_client.dart';
import '../../../core/network/core_network_providers.dart';
import '../../bookings/domain/booked_item.dart';
import '../data/cart_api.dart';
import '../data/cart_repository.dart';

final cartRepositoryProvider = Provider<CartRepository>((ref) {
  final ApiClient client = ref.watch(apiClientProvider);
  return CartRepository(api: CartApi(client));
});

final cartItemsProvider = FutureProvider<List<BookedItem>>((ref) async {
  final repo = ref.read(cartRepositoryProvider);
  return repo.getCartItems();
});

final cartControllerProvider = AsyncNotifierProvider<CartController, void>(
  CartController.new,
);

class CartController extends AsyncNotifier<void> {
  @override
  Future<void> build() async {}

  Future<void> addToCart({
    required String pricingId,
    required String startTime,
    required int duration,
    Map<String, dynamic>? meta,
  }) async {
    state = const AsyncLoading();
    try {
      final repo = ref.read(cartRepositoryProvider);
      await repo.addToCart(
        pricingId: pricingId,
        startTime: startTime,
        duration: duration,
        meta: meta,
      );
      ref.invalidate(cartItemsProvider);
      state = const AsyncData(null);
    } catch (e, st) {
      state = AsyncError(e, st);
      rethrow;
    }
  }

  Future<void> removeItem({required String bagItemId}) async {
    state = const AsyncLoading();
    try {
      final repo = ref.read(cartRepositoryProvider);
      await repo.removeCartItem(bagItemId: bagItemId);
      ref.invalidate(cartItemsProvider);
      state = const AsyncData(null);
    } catch (e, st) {
      state = AsyncError(e, st);
      rethrow;
    }
  }

  Future<void> updateCartItem({
    required String bagItemId,
    required Map<String, dynamic> data,
  }) async {
    state = const AsyncLoading();
    try {
      final repo = ref.read(cartRepositoryProvider);
      await repo.updateCartItem(bagItemId: bagItemId, data: data);
      ref.invalidate(cartItemsProvider);
      state = const AsyncData(null);
    } catch (e, st) {
      state = AsyncError(e, st);
      rethrow;
    }
  }

  Future<CartCheckoutResult> checkout() async {
    state = const AsyncLoading();
    try {
      final repo = ref.read(cartRepositoryProvider);
      final result = await repo.checkout();
      ref.invalidate(cartItemsProvider);
      state = const AsyncData(null);
      return result;
    } catch (e, st) {
      state = AsyncError(e, st);
      rethrow;
    }
  }
}
