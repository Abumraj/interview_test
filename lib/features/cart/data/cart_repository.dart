import '../../bookings/domain/booked_item.dart';
import 'cart_api.dart';

class CartBagItem {
  final String id;
  final String bagId;
  final String productId;
  final String pricingId;
  final DateTime? startTime;
  final int? duration;
  final String? category;
  final String? resourceCategory;
  final int? totalPriceSnapshot;
  final Map<String, dynamic> meta;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final String? productImage;
  final bool isAvailable;

  const CartBagItem({
    required this.id,
    required this.bagId,
    required this.productId,
    required this.pricingId,
    required this.startTime,
    required this.duration,
    required this.category,
    required this.resourceCategory,
    required this.totalPriceSnapshot,
    required this.meta,
    required this.createdAt,
    required this.updatedAt,
    this.productImage,
    this.isAvailable = true,
  });

  factory CartBagItem.fromJson(Map<String, dynamic> json) {
    DateTime? parseDate(Object? v) {
      if (v == null) return null;
      if (v is DateTime) return v;
      return DateTime.tryParse(v.toString());
    }

    final rawMeta = json['meta'];
    final meta =
        rawMeta is Map<String, dynamic>
            ? rawMeta
            : rawMeta is Map
            ? Map<String, dynamic>.from(rawMeta)
            : const <String, dynamic>{};

    return CartBagItem(
      id: json['id']?.toString() ?? json['_id']?.toString() ?? '',
      bagId: json['bagId']?.toString() ?? '',
      productId: json['productId']?.toString() ?? '',
      pricingId: json['pricingId']?.toString() ?? '',
      startTime: parseDate(json['startTime']),
      duration: (json['duration'] as num?)?.toInt(),
      category: json['category']?.toString(),
      resourceCategory: json['resourceCategory']?.toString(),
      totalPriceSnapshot: (json['totalPriceSnapshot'] as num?)?.toInt(),
      meta: meta,
      createdAt: parseDate(json['createdAt']),
      updatedAt: parseDate(json['updatedAt']),
      productImage: json['productImage']?.toString(),
      isAvailable: json['isAvailable'] == true,
    );
  }
}

class CartBag {
  final String id;
  final String userId;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final List<CartBagItem> bagItems;

  const CartBag({
    required this.id,
    required this.userId,
    required this.createdAt,
    required this.updatedAt,
    required this.bagItems,
  });

  factory CartBag.fromJson(Map<String, dynamic> json) {
    DateTime? parseDate(Object? v) {
      if (v == null) return null;
      if (v is DateTime) return v;
      return DateTime.tryParse(v.toString());
    }

    final itemsRaw = json['bagItems'];
    final items =
        itemsRaw is List
            ? itemsRaw
                .whereType<Map>()
                .map((e) => CartBagItem.fromJson(Map<String, dynamic>.from(e)))
                .toList(growable: false)
            : const <CartBagItem>[];

    return CartBag(
      id: json['id']?.toString() ?? json['_id']?.toString() ?? '',
      userId: json['userId']?.toString() ?? '',
      createdAt: parseDate(json['createdAt']),
      updatedAt: parseDate(json['updatedAt']),
      bagItems: items,
    );
  }
}

class CartCheckoutResult {
  final String paymentId;
  final int totalAmount;

  const CartCheckoutResult({
    required this.paymentId,
    required this.totalAmount,
  });

  factory CartCheckoutResult.fromJson(Map<String, dynamic> json) {
    return CartCheckoutResult(
      paymentId: json['paymentId']?.toString() ?? '',
      totalAmount: (json['totalAmount'] as num?)?.toInt() ?? 0,
    );
  }
}

class CartRepository {
  CartRepository({required CartApi api}) : _api = api;

  final CartApi _api;

  CartBag? _parseCartBag(Object? json) {
    Object? raw = json;
    for (var i = 0; i < 3; i++) {
      if (raw is Map<String, dynamic>) {
        raw = raw['data'] ?? raw['result'] ?? raw;
        continue;
      }
      if (raw is Map) {
        final m = Map<String, dynamic>.from(raw);
        raw = m['data'] ?? m['result'] ?? raw;
        continue;
      }
      break;
    }

    if (raw is Map<String, dynamic>) {
      return CartBag.fromJson(raw);
    }
    if (raw is Map) {
      return CartBag.fromJson(Map<String, dynamic>.from(raw));
    }
    return null;
  }

  List<BookedItem> _bagToBookedItems(CartBag bag) {
    return bag.bagItems
        .map((e) {
          final qtyFromMeta = (e.meta['quantity'] as num?)?.toInt();
          final people = (e.meta['people'] as num?)?.toInt();
          final qty = qtyFromMeta ?? people ?? 1;
          final priceFromMeta = (e.meta['price'] as num?)?.toInt();
          final amountFromMeta = (e.meta['amount'] as num?)?.toInt();
          final price = priceFromMeta ?? e.totalPriceSnapshot;
          final amount = amountFromMeta ?? e.totalPriceSnapshot;

          final name =
              e.meta['name']?.toString().trim().isNotEmpty == true
                  ? e.meta['name']!.toString()
                  : (e.category?.toString() ?? e.productId);
          final imageUrl =
              e.productImage ??
              e.meta['imageUrl']?.toString() ??
              e.meta['image']?.toString();
          final variantType =
              e.meta['type']?.toString() ??
              e.meta['variant']?.toString() ??
              e.resourceCategory;

          return BookedItem(
            id: e.id,
            name: name,
            imageUrl: imageUrl,
            variantType: variantType,
            price: price,
            quantity: qty,
            duration: e.duration,
            date: e.startTime ?? e.createdAt,
            amount: amount,
            bonusPoint: null,
            isAvailable: e.isAvailable,
            productId: e.productId,
            pricingId: e.pricingId,
            category: e.category,
            resourceCategory: e.resourceCategory,
            meta: e.meta,
          );
        })
        .toList(growable: false);
  }

  Future<void> addToCart({
    required String pricingId,
    required String startTime,
    required int duration,
    Map<String, dynamic>? meta,
  }) async {
    await _api.addToCart(
      pricingId: pricingId,
      startTime: startTime,
      duration: duration,
      meta: meta,
    );
  }

  Future<List<BookedItem>> getCartItems() async {
    final json = await _api.getCartItems();
    final bag = _parseCartBag(json);
    if (bag == null) return const <BookedItem>[];
    return _bagToBookedItems(bag);
  }

  Future<void> removeCartItem({required String bagItemId}) async {
    await _api.removeCartItem(bagItemId: bagItemId);
  }

  Future<void> updateCartItem({
    required String bagItemId,
    required Map<String, dynamic> data,
  }) async {
    await _api.updateCartItem(bagItemId: bagItemId, data: data);
  }

  Future<CartCheckoutResult> checkout() async {
    final json = await _api.checkout();

    Object? raw = json;
    if (raw is Map<String, dynamic>) {
      raw = raw['data'] ?? raw['result'] ?? raw;
    }
    if (raw is Map) {
      return CartCheckoutResult.fromJson(Map<String, dynamic>.from(raw));
    }

    return const CartCheckoutResult(paymentId: '', totalAmount: 0);
  }
}
