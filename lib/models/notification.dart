class NotificationData {
  NotificationData({
    required this.id,
    required this.title,
    required this.message,
    this.image,
    required this.isRead,
    required this.createdAt,
  });

  final String id;
  final String? title;
  final bool isRead;
  final String? message;
  final String? image;
  final DateTime? createdAt;

  factory NotificationData.fromJson(Map<String, dynamic> json) {
    return NotificationData(
      id: json['id']?.toString() ?? '',
      title: json['title']?.toString(),
      isRead: json['isRead'] is bool ? json['isRead'] as bool : false,
      message: json['body']?.toString() ?? json['message']?.toString(),
      image: json['image']?.toString(),
      createdAt: DateTime.tryParse(json['createdAt']?.toString() ?? ''),
    );
  }

  NotificationData copyWith({bool? isRead}) {
    return NotificationData(
      id: id,
      title: title,
      message: message,
      image: image,
      isRead: isRead ?? this.isRead,
      createdAt: createdAt,
    );
  }
}
