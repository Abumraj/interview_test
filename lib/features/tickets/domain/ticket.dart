class Ticket {
  final String id;
  final String? bookingId;
  final String? eventName;
  final String? date;
  final String? time;
  final String? qrPayload;
  final bool? isGroupBooking;
  final String? ticketPosition;

  final String? eventTitle;
  final String? eventDate;
  final String? qr;
  final String? eventImage;
  final Map<String, dynamic>? raw;

  const Ticket({
    required this.id,
    this.bookingId,
    this.eventName,
    this.date,
    this.time,
    this.qrPayload,
    this.isGroupBooking,
    this.ticketPosition,
    this.eventTitle,
    this.eventDate,
    this.qr,
    this.eventImage,
    this.raw,
  });

  factory Ticket.fromJson(Map<String, dynamic> json) {
    final bookingId = json['bookingId']?.toString();
    final id =
        bookingId ?? json['id']?.toString() ?? json['_id']?.toString() ?? '';

    // Try to infer event info from common backend shapes.
    final event = json['event'];
    String? title;
    String? date;
    String? image;
    if (event is Map<String, dynamic>) {
      title = event['title']?.toString() ?? event['name']?.toString();
      date = event['date']?.toString() ?? event['startDate']?.toString();
      image = event['eventImg']?.toString() ?? event['image']?.toString();
    }

    return Ticket(
      id: id,
      bookingId: bookingId,
      eventName: json['title']?.toString(),
      date: json['date']?.toString(),
      time: json['time']?.toString(),
      qrPayload: json['qrPayload']?.toString(),
      isGroupBooking: json['isGroupBooking'] as bool?,
      ticketPosition: (json['ticketPosition'])?.toString(),
      eventTitle:
          title ?? json['title']?.toString() ?? json['eventName']?.toString(),
      eventDate:
          date ?? json['eventDate']?.toString() ?? json['date']?.toString(),
      qr:
          json['qr']?.toString() ??
          json['qrCode']?.toString() ??
          json['qrPayload']?.toString(),
      eventImage: image ?? json['eventImage']?.toString(),
      raw: json,
    );
  }
}
