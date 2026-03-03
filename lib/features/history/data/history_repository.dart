import '../../../core/cache/cache_keys.dart';
import '../../../core/cache/cache_manager.dart';
import '../domain/purchase.dart';
import '../domain/purchase_details.dart';
import 'history_api.dart';

class HistoryRepository {
  HistoryRepository({required HistoryApi api, required CacheManager cache})
    : _api = api,
      _cache = cache;

  final HistoryApi _api;
  final CacheManager _cache;

  List<Purchase> _parsePurchases(Object? json) {
    Object? raw = json;
    if (raw is Map<String, dynamic>) {
      raw = raw['data'] ?? raw['purchases'] ?? raw['results'] ?? raw['items'];
    }

    if (raw is List) {
      return raw
          .whereType<Map>()
          .map((e) => Purchase.fromJson(Map<String, dynamic>.from(e)))
          .toList(growable: false);
    }

    return const <Purchase>[];
  }

  Future<List<Purchase>> getPurchasesCachedFirst(String userId) async {
    final cached = await _cache.readJson(CacheKeys.purchasesList);
    if (cached != null) {
      return _parsePurchases(cached);
    }

    final fresh = await _api.getMyPurchases(userId);
    if (fresh is Map<String, dynamic>) {
      await _cache.writeJson(CacheKeys.purchasesList, fresh);
    } else if (fresh is List) {
      await _cache.writeJson(CacheKeys.purchasesList, <String, dynamic>{
        'data': fresh,
      });
    }

    return _parsePurchases(fresh);
  }

  Future<void> revalidatePurchasesInBackground(String userId) async {
    try {
      final fresh = await _api.getMyPurchases(userId);
      if (fresh is Map<String, dynamic>) {
        await _cache.writeJson(CacheKeys.purchasesList, fresh);
      } else if (fresh is List) {
        await _cache.writeJson(CacheKeys.purchasesList, <String, dynamic>{
          'data': fresh,
        });
      }
    } catch (_) {
      // ignore
    }
  }

  PurchaseDetails? _parsePurchaseDetails(Object? json) {
    Object? raw = json;
    if (raw is Map<String, dynamic>) {
      raw = raw['data'] ?? raw['result'] ?? raw;
    }
    if (raw is Map<String, dynamic>) {
      return PurchaseDetails.fromJson(raw);
    }
    return null;
  }

  Future<PurchaseDetails?> getPurchaseDetails(String bookingId) async {
    final json = await _api.getPurchaseDetails(bookingId);
    return _parsePurchaseDetails(json);
  }
}
