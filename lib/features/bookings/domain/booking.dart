class Booking {
  final String id;
  final String paymentId;

  const Booking({required this.id, required this.paymentId});

  factory Booking.fromJson(Map<String, dynamic> json) {
    final id = json['id']?.toString();
    final paymentId = json['paymentId']?.toString();
    return Booking(id: id ?? '', paymentId: paymentId ?? '');
  }
}
