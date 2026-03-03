import '../../../core/network/api_client.dart';

class ProductsApi {
  ProductsApi(this._client);

  final ApiClient _client;

  Future<Map<String, dynamic>> getAllProducts() {
    return _client.get<Map<String, dynamic>>('/products');
  }

  Future<Map<String, dynamic>> getProductById(String id) {
    return _client.get<Map<String, dynamic>>('/products/$id');
  }
}
