class Event {
  final String id;
  final String? title;
  final String? description;
  final String? address;
  final String? eventImg;
  final String? time;
  final num? price;
  final num? capacity;
  final String? eventType;
  final bool? isActive;
  final String? recurrenceRule;
  final DateTime? startDate;
  final DateTime? endDate;
  final DateTime? deadline;
  final bool? isCapacityLimited;
  final bool isBookable;
  final String? displayDay;
  final String? statusReason;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final List<EventSlot> slots;

  const Event({
    required this.id,
    this.title,
    this.description,
    this.address,
    this.eventImg,
    this.time,
    this.price,
    this.capacity,
    this.eventType,
    this.isActive,
    this.recurrenceRule,
    this.startDate,
    this.endDate,
    this.deadline,
    this.isCapacityLimited,
    this.isBookable = true,
    this.displayDay,
    this.statusReason,
    this.createdAt,
    this.updatedAt,
    this.slots = const <EventSlot>[],
  });

  factory Event.fromJson(Map<String, dynamic> json) {
    DateTime? parseDate(dynamic v) {
      if (v == null) return null;
      if (v is DateTime) return v;
      return DateTime.tryParse(v.toString());
    }

    final slotsRaw = json['slots'];
    final slots =
        slotsRaw is List
            ? slotsRaw
                .whereType<Map>()
                .map((e) => EventSlot.fromJson(Map<String, dynamic>.from(e)))
                .toList(growable: false)
            : const <EventSlot>[];

    final id = json['id']?.toString();
    return Event(
      id: id ?? '',
      title: json['title']?.toString() ?? json['name']?.toString(),
      description: json['description']?.toString(),
      address: json['address']?.toString(),
      time: json['time']?.toString(),
      eventImg: json['eventImg']?.toString() ?? json['image']?.toString(),
      price:
          json['price'] is num
              ? json['price'] as num
              : num.tryParse('${json['price']}'),
      capacity:
          json['capacity'] is num
              ? json['capacity'] as num
              : num.tryParse('${json['capacity']}'),
      eventType: json['eventType']?.toString(),
      isActive: json['isActive'] is bool ? json['isActive'] as bool : null,
      recurrenceRule: json['recurrenceRule']?.toString(),
      startDate: parseDate(json['startDate']),
      endDate: parseDate(json['endDate']),
      deadline: parseDate(json['deadline']),
      isCapacityLimited:
          json['isCapacityLimited'] is bool
              ? json['isCapacityLimited'] as bool
              : null,
      isBookable:
          json['isBookable'] is bool ? json['isBookable'] as bool : true,
      displayDay: json['displayDay']?.toString(),
      statusReason: json['statusReason']?.toString(),
      createdAt: parseDate(json['createdAt']),
      updatedAt: parseDate(json['updatedAt']),
      slots: slots,
    );
  }
}

class EventSlot {
  final String slotId;
  final int availableSlots;
  final int? capacity;
  final DateTime? startTime;

  const EventSlot({
    required this.slotId,
    required this.availableSlots,
    this.capacity,
    required this.startTime,
  });

  factory EventSlot.fromJson(Map<String, dynamic> json) {
    DateTime? parseDate(dynamic v) {
      if (v == null) return null;
      if (v is DateTime) return v;
      return DateTime.tryParse(v.toString());
    }

    return EventSlot(
      slotId: (json['slotId']?.toString() ?? json['id']?.toString()) ?? '',
      availableSlots:
          (json['available'] as num?)?.toInt() ??
          (json['availableSlots'] as num?)?.toInt() ??
          0,
      capacity: (json['capacity'] as num?)?.toInt(),
      startTime: parseDate(json['startTime']),
    );
  }
}
