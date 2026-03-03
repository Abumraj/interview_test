import '../../../core/cache/cache_keys.dart';
import '../../../core/cache/cache_manager.dart';
import '../domain/product.dart';
import 'products_api.dart';

class ProductsRepository {
  ProductsRepository({required ProductsApi api, required CacheManager cache})
    : _api = api,
      _cache = cache;

  final ProductsApi _api;
  final CacheManager _cache;

  Future<List<Product>> getProductsCachedFirst() async {
    final cached = await _cache.readJson(CacheKeys.productsList);
    if (cached != null) {
      final data = cached['data'];
      if (data is List) {
        return data
            .whereType<Map<String, dynamic>>()
            .map(Product.fromJson)
            .toList(growable: false);
      }
    }

    final fresh = await _api.getAllProducts();
    await _cache.writeJson(CacheKeys.productsList, fresh);

    final data = fresh['data'];
    if (data is List) {
      return data
          .whereType<Map<String, dynamic>>()
          .map(Product.fromJson)
          .toList(growable: false);
    }
    return const <Product>[];
  }

  Future<void> revalidateProductsInBackground() async {
    final fresh = await _api.getAllProducts();
    await _cache.writeJson(CacheKeys.productsList, fresh);
  }

  Future<Product?> getProductDetailsCachedFirst(String id) async {
    final fresh = await _api.getProductById(id);

    final data = fresh['data'];
    if (data is Map<String, dynamic>) {
      return Product.fromJson(data);
    }
    return null;
  }

  Future<void> revalidateProductDetailsInBackground(String id) async {
    await _api.getProductById(id);
  }
}
