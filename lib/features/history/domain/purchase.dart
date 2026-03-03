class Purchase {
  final String id;
  final num? totalPrice;
  final String? createdAt;
  final Map<String, dynamic>? raw;

  const Purchase({required this.id, this.totalPrice, this.createdAt, this.raw});

  factory Purchase.fromJson(Map<String, dynamic> json) {
    final id =
        json['bookingId']?.toString() ??
        json['id']?.toString() ??
        json['_id']?.toString() ??
        '';
    return Purchase(
      id: id,
      totalPrice:
          (json['amount'] as num?) ??
          (json['totalPrice'] is num
              ? json['totalPrice'] as num
              : num.tryParse('${json['totalPrice']}')),
      createdAt:
          json['date']?.toString() ?? json['createdAt']?.toString() ?? '',
      raw: json,
    );
  }
}
