/// Represents a system or ticket notification for the user.
/// Named [AppNotification] to avoid conflicts with Flutter's internal Notification class.
class AppNotification {
  final String id;
  final String type;
  final Map<String, dynamic> data;
  final DateTime? readAt;
  final DateTime createdAt;

  /// Helper to easily check if the notification is unread.
  bool get isRead => readAt != null;

  AppNotification({
    required this.id,
    required this.type,
    required this.data,
    this.readAt,
    required this.createdAt,
  });

  /// Maps the API JSON response to our Dart domain model.
  factory AppNotification.fromJson(Map<String, dynamic> json) {
    return AppNotification(
      id: json['id'] as String,
      type: json['type'] as String,
      data: json['data'] as Map<String, dynamic>? ?? {},
      readAt: json['read_at'] != null ? DateTime.parse(json['read_at'] as String) : null,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }
}