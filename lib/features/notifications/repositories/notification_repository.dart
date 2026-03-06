import '../../../core/network/api_client.dart';
import '../models/app_notification.dart';

/// Repository responsible for handling notification-related data operations.
/// 
/// Communicates with the backend API to fetch, read and manage app notifications.
class NotificationRepository {
  /// The HTTP client used for making API requests.
  final ApiClient apiClient;

  /// Creates a new instance of [NotificationRepository].
  NotificationRepository({required this.apiClient});

  /// Fetches a list of notifications for the authenticated user.
  /// 
  /// Handles Laravel's paginated responses and custom API wrappers to extract
  /// the notification list correctly.
  /// 
  /// Returns a [Future] containing a list of [AppNotification].
  Future<List<AppNotification>> getNotifications() async {
    final Map<String, dynamic> response = await apiClient.get('/notifications');
    
    List<dynamic> rawList = [];

    dynamic payload = response['data'] ?? response;

    if (payload is Map && payload.containsKey('data') && payload['data'] is List) {
      rawList = payload['data'];
    } else if (payload is List) {
      rawList = payload;
    } else if (payload is Map) {
      payload.forEach((key, value) {
        if (key != 'current_page' && key != 'total' && key != 'links' && value is Map) {
          rawList.add(value);
        }
      });
    }

    final List<AppNotification> notifications = [];
    
    for (var item in rawList) {
      if (item is Map) {
        notifications.add(AppNotification.fromJson(Map<String, dynamic>.from(item)));
      }
    }

    return notifications;
  }

  /// Marks a specific notification as read.
  /// 
  /// [notificationId] The unique identifier of the notification to be marked as read.
  Future<void> markAsRead(String notificationId) async {
    await apiClient.patch('/notifications/$notificationId/read');
  }

  /// Marks all unread notifications for the user as read.
  Future<void> markAllAsRead() async {
    await apiClient.post('/notifications/read-bulk');
  }

  /// Permanently deletes a specific notification.
  /// 
  /// [notificationId] The unique identifier of the notification to delete.
  Future<void> deleteNotification(String notificationId) async {
    await apiClient.delete('/notifications/$notificationId');
  }

  /// Clears (deletes) all notifications for the authenticated user.
  Future<void> clearAllNotifications() async {
    await apiClient.post('/notifications/clear');
  }
}