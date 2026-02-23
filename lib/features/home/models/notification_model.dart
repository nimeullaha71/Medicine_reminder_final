class NotificationResponse {
  final int unreadCount;
  final int readCount;
  final List<NotificationModel> notifications;

  NotificationResponse({
    required this.unreadCount,
    required this.readCount,
    required this.notifications,
  });

  factory NotificationResponse.fromJson(Map<String, dynamic> json) {
    return NotificationResponse(
      unreadCount: json['unread_count'] ?? 0,
      readCount: json['read_count'] ?? 0,
      notifications: (json['notifications'] as List? ?? [])
          .map((i) => NotificationModel.fromJson(i))
          .toList(),
    );
  }
}

class NotificationModel {
  final int id;
  final String notificationType;
  final String title;
  final String body;
  final bool isSent;
  final bool isRead;
  final DateTime sentAt;
  final dynamic medicine;

  NotificationModel({
    required this.id,
    required this.notificationType,
    required this.title,
    required this.body,
    required this.isSent,
    required this.isRead,
    required this.sentAt,
    this.medicine,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      id: json['id'],
      notificationType: json['notification_type'],
      title: json['title'],
      body: json['body'],
      isSent: json['is_sent'],
      isRead: json['is_read'],
      sentAt: DateTime.parse(json['sent_at']),
      medicine: json['medicine'],
    );
  }
}
