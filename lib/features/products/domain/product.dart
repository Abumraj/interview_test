class ProductMeta {
  final List<String> features;
  final String? description;
  final Map<String, int> routes;

  const ProductMeta({
    required this.features,
    this.description,
    this.routes = const <String, int>{},
  });

  factory ProductMeta.fromJson(Map<String, dynamic> json) {
    final rawFeatures = json['features'];

    Map<String, int> parseRoutes(Object? raw) {
      if (raw is! Map) return const <String, int>{};
      final out = <String, int>{};
      for (final entry in raw.entries) {
        final k = entry.key?.toString();
        if (k == null || k.isEmpty) continue;
        final v = entry.value;
        if (v is num) {
          out[k] = v.toInt();
        } else if (v is String) {
          final parsed = int.tryParse(v);
          if (parsed != null) out[k] = parsed;
        }
      }
      return out;
    }

    final routesRaw = json['routes'];
    return ProductMeta(
      features:
          rawFeatures is List
              ? rawFeatures.whereType<String>().toList(growable: false)
              : const <String>[],
      description: json['description'] as String?,
      routes: parseRoutes(routesRaw),
    );
  }
}

class ProductPricing {
  final String id;
  final String? productId;
  final int? seatCapacity;
  final String? location;
  final String? label;
  final int? hourlyRate;
  final List<ProductPricingOption> options;
  final int duration;
  final int price;
  final String? createdAt;
  final String? updatedAt;

  const ProductPricing({
    required this.id,
    this.productId,
    this.seatCapacity,
    this.location,
    this.label,
    this.hourlyRate,
    this.options = const <ProductPricingOption>[],
    required this.duration,
    required this.price,
    this.createdAt,
    this.updatedAt,
  });

  factory ProductPricing.fromJson(Map<String, dynamic> json) {
    final optionsRaw = json['options'] ?? json['types'];
    final options =
        optionsRaw is List
            ? optionsRaw
                .whereType<Map<String, dynamic>>()
                .map(ProductPricingOption.fromJson)
                .toList(growable: false)
            : const <ProductPricingOption>[];

    final fallbackDuration =
        options.isNotEmpty ? (options.first.duration * 60) : 0;
    final fallbackPrice = options.isNotEmpty ? options.first.totalPrice : 0;

    return ProductPricing(
      id: (json['id']?.toString() ?? json['pricingId']?.toString()) ?? '',
      productId: json['productId'] as String?,
      seatCapacity: (json['seatCapacity'] as num?)?.toInt(),
      location: json['location']?.toString(),
      label: json['label']?.toString(),
      hourlyRate: (json['hourlyRate'] as num?)?.toInt(),
      options: options,
      duration: (json['duration'] as num?)?.toInt() ?? fallbackDuration,
      price:
          (json['price'] as num?)?.toInt() ??
          (json['basePrice'] as num?)?.toInt() ??
          fallbackPrice,
      createdAt: json['createdAt']?.toString(),
      updatedAt: json['updatedAt']?.toString(),
    );
  }
}

class ProductPricingOption {
  final String? id;
  final int duration;
  final int totalPrice;
  final String? displayLabel;

  const ProductPricingOption({
    this.id,
    required this.duration,
    required this.totalPrice,
    this.displayLabel,
  });

  factory ProductPricingOption.fromJson(Map<String, dynamic> json) {
    return ProductPricingOption(
      id: json['id']?.toString(),
      duration: (json['duration'] as num?)?.toInt() ?? 0,
      totalPrice: (json['totalPrice'] as num?)?.toInt() ?? 0,
      displayLabel:
          json['displayLabel']?.toString() ?? json['label']?.toString(),
    );
  }
}

class ProductTimeSlot {
  final String slotId;
  final DateTime? startTime;
  final DateTime? endTime;
  final int remaining;
  final bool isAvailable;
  final List<int> availableBoatSizes;
  final Map<int, int> availableUnitsByBoatSize;

  const ProductTimeSlot({
    required this.slotId,
    required this.startTime,
    required this.endTime,
    required this.remaining,
    required this.isAvailable,
    this.availableBoatSizes = const <int>[],
    this.availableUnitsByBoatSize = const <int, int>{},
  });

  factory ProductTimeSlot.fromJson(Map<String, dynamic> json) {
    DateTime? parseDate(dynamic v) {
      if (v == null) return null;
      if (v is DateTime) return v;
      return DateTime.tryParse(v.toString());
    }

    int? parseBoatSize(String? category) {
      if (category == null) return null;
      final match = RegExp(r'(\d+)').firstMatch(category);
      if (match == null) return null;
      return int.tryParse(match.group(1) ?? '');
    }

    List<int> parseIntList(dynamic v) {
      if (v is! List) return const <int>[];
      return v
          .map((e) => e is num ? e.toInt() : int.tryParse(e.toString()))
          .whereType<int>()
          .toList(growable: false);
    }

    final resourcesRaw = json['resources'];
    final unitsBySize = <int, int>{};
    int totalUnits = 0;
    if (resourcesRaw is List) {
      for (final r in resourcesRaw) {
        if (r is! Map) continue;
        final category = r['category']?.toString();
        final availableUnits = (r['availableUnits'] as num?)?.toInt() ?? 0;

        totalUnits += availableUnits;

        final size = parseBoatSize(category);
        if (size == null) continue;
        unitsBySize[size] = availableUnits;
      }
    }

    final derivedAvailableBoatSizes = unitsBySize.entries
        .where((e) => e.value >= 1)
        .map((e) => e.key)
        .toList(growable: false);
    derivedAvailableBoatSizes.sort();

    final legacyBoatSizes = parseIntList(json['availableBoatSizes']);
    final availableBoatSizes =
        derivedAvailableBoatSizes.isNotEmpty
            ? derivedAvailableBoatSizes
            : legacyBoatSizes;

    final remaining = (json['remaining'] as num?)?.toInt() ?? totalUnits;
    final isAvailable = (json['isAvailable'] as bool?) ?? (remaining >= 1);

    return ProductTimeSlot(
      slotId: (json['slotId']?.toString() ?? json['id']?.toString()) ?? '',
      startTime: parseDate(json['startTime']),
      endTime: parseDate(json['endTime']),
      remaining: remaining,
      isAvailable: isAvailable,
      availableBoatSizes: availableBoatSizes,
      availableUnitsByBoatSize: unitsBySize,
    );
  }
}

class Product {
  final String id;
  final String name;
  final String? category;
  final ProductMeta? meta;
  final String? description;
  final String? capacity;
  final int availability;
  final bool isActive;
  final String? productImage;
  final String? createdAt;
  final String? updatedAt;
  final List<ProductPricing> pricing;
  final List<ProductTimeSlot> timeSlots;
  final List<String> images;

  const Product({
    required this.id,
    required this.name,
    required this.availability,
    required this.isActive,
    this.category,
    this.meta,
    this.description,
    this.capacity,
    this.productImage,
    this.createdAt,
    this.updatedAt,
    this.pricing = const <ProductPricing>[],
    this.timeSlots = const <ProductTimeSlot>[],
    this.images = const <String>[],
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    final pricingRaw = json['pricing'];
    final imagesRaw = json['images'];
    final timeSlotsRaw = json['timeSlots'];

    return Product(
      id: (json['id'] as String?) ?? '',
      name: (json['name'] as String?) ?? '',
      category: json['category'] as String?,
      meta:
          json['meta'] is Map<String, dynamic>
              ? ProductMeta.fromJson(json['meta'] as Map<String, dynamic>)
              : null,
      description: json['description']?.toString(),
      capacity: json['capacity'] as String?,
      availability: (json['availability'] as num?)?.toInt() ?? 0,
      isActive: (json['isActive'] as bool?) ?? true,
      productImage:
          json['productImage']?.toString() ?? json['image']?.toString(),
      createdAt: json['createdAt']?.toString(),
      updatedAt: json['updatedAt']?.toString(),
      pricing:
          pricingRaw is List
              ? pricingRaw
                  .whereType<Map<String, dynamic>>()
                  .map(ProductPricing.fromJson)
                  .toList(growable: false)
              : const <ProductPricing>[],
      timeSlots:
          timeSlotsRaw is List
              ? timeSlotsRaw
                  .whereType<Map<String, dynamic>>()
                  .map(ProductTimeSlot.fromJson)
                  .toList(growable: false)
              : const <ProductTimeSlot>[],
      images:
          imagesRaw is List
              ? imagesRaw.whereType<String>().toList(growable: false)
              : const <String>[],
    );
  }

  String get primaryImageUrl {
    if (productImage != null && productImage!.trim().isNotEmpty) {
      return productImage!.trim();
    }
    return images.isNotEmpty ? images.first : '';
  }

  int? get minPrice {
    if (pricing.isEmpty) return null;
    final prices = <int>[];

    for (final p in pricing) {
      if (p.options.isNotEmpty) {
        prices.addAll(p.options.map((o) => o.totalPrice).where((e) => e > 0));
        continue;
      }
      if (p.price > 0) prices.add(p.price);
    }

    if (prices.isEmpty) return null;
    prices.sort();
    return prices.first;
  }
}
