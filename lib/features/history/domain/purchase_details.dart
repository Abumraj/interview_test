class PurchaseDetails {
  final String leisureType;
  final int? capacity;
  final int? duration;
  final int? amount;
  final String? dateTime;
  final String? transactionId;
  final String? transactionType;
  final String? qrPayload;

  const PurchaseDetails({
    required this.leisureType,
    this.capacity,
    this.duration,
    this.amount,
    this.dateTime,
    this.transactionType,
    this.transactionId,
    this.qrPayload,
  });

  factory PurchaseDetails.fromJson(Map<String, dynamic> json) {
    return PurchaseDetails(
      leisureType: json['leisureType']?.toString() ?? '',
      capacity: (json['capacity'] as num?)?.toInt(),
      duration: (json['duration'] as num?)?.toInt(),
      amount: (json['amount'] as num?)?.toInt(),
      dateTime:
          json['startTime']?.toString() ??
          json['dateTime']?.toString() ??
          json['date']?.toString() ??
          json['createdAt']?.toString(),
      transactionType:
          json['transactionType']?.toString() ??
          json['type']?.toString() ??
          json['bookingType']?.toString(),
      transactionId:
          json['transactionId']?.toString() ??
          json['txRef']?.toString() ??
          json['ref']?.toString() ??
          json['id']?.toString(),
      qrPayload: json['qrPayload']?.toString(),
    );
  }
}
