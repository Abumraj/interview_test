class BookedItem {
  final String id;
  final String name;
  final String? imageUrl;
  final String? variantType;
  final int? price;
  final int? quantity;
  final int? duration;
  final DateTime? date;
  final int? amount;
  final int? bonusPoint;
  final bool? isAvailable;
  final String? productId;
  final String? pricingId;
  final String? category;
  final String? resourceCategory;
  final Map<String, dynamic>? meta;

  const BookedItem({
    required this.id,
    required this.name,
    this.imageUrl,
    this.variantType,
    this.price,
    this.quantity,
    this.duration,
    this.date,
    this.amount,
    this.bonusPoint,
    this.isAvailable,
    this.productId,
    this.pricingId,
    this.category,
    this.resourceCategory,
    this.meta,
  });

  factory BookedItem.fromJson(Map<String, dynamic> json) {
    final meta = json['meta'];
    final metaMap =
        meta is Map<String, dynamic> ? meta : const <String, dynamic>{};

    DateTime? parseDate(Object? v) {
      if (v == null) return null;
      if (v is DateTime) return v;
      return DateTime.tryParse(v.toString());
    }

    return BookedItem(
      id: json['id']?.toString() ?? json['_id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      imageUrl:
          metaMap['imageUrl']?.toString() ??
          metaMap['image']?.toString() ??
          json['imageUrl']?.toString() ??
          json['image']?.toString(),
      variantType:
          metaMap['type']?.toString() ??
          metaMap['variant']?.toString() ??
          json['type']?.toString(),
      price:
          (metaMap['price'] as num?)?.toInt() ??
          (json['price'] as num?)?.toInt(),
      quantity:
          (metaMap['quantity'] as num?)?.toInt() ??
          (json['capacity'] as num?)?.toInt(),
      duration: (json['duration'] as num?)?.toInt(),
      date: parseDate(json['date'] ?? json['createdAt']),
      amount: (json['amount'] as num?)?.toInt(),
      bonusPoint: (json['bonusPoint'] as num?)?.toInt(),
    );
  }
}
