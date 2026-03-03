import '../../../core/network/api_client.dart';

class CartApi {
  CartApi(this._client);

  final ApiClient _client;

  Future<Map<String, dynamic>> addToCart({
    required String pricingId,
    required String startTime,
    required int duration,
    Map<String, dynamic>? meta,
  }) {
    return _client.post<Map<String, dynamic>>(
      '/cart',
      data: <String, dynamic>{
        'pricingId': pricingId,
        'startTime': startTime,
        'duration': duration,
        'meta': meta,
      },
    );
  }

  Future<Map<String, dynamic>> getCartItems() {
    return _client.get<Map<String, dynamic>>('/cart');
  }

  Future<void> removeCartItem({required String bagItemId}) async {
    await _client.delete<Object?>('/cart/$bagItemId');
  }

  Future<Map<String, dynamic>> updateCartItem({
    required String bagItemId,
    required Map<String, dynamic> data,
  }) {
    return _client.patch<Map<String, dynamic>>('/cart/$bagItemId', data: data);
  }

  Future<Map<String, dynamic>> checkout() {
    return _client.post<Map<String, dynamic>>('/cart/checkout');
  }
}
