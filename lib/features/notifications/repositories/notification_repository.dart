import '../../../core/network/api_client.dart';
import '../models/app_notification.dart';

/// Repository responsible for handling system and ticket notifications.
class NotificationRepository {
  /// The API client used to perform HTTP requests.
  final ApiClient apiClient;

  /// Initializes the NotificationRepository.
  ///
  /// The [apiClient] parameter is strictly required for network communication.
  NotificationRepository({required this.apiClient});

  /// Fetches a paginated list of notifications for the authenticated user.
  ///
  /// Returns a list of [AppNotification] objects.
  Future<List<AppNotification>> getNotifications() async {
    final Map<String, dynamic> response = await apiClient.get('/notifications');
    
    // Handles standard Laravel pagination/resource wrapping structure
    final List<dynamic> dataList = response.containsKey('data') 
        ? response['data'] 
        : response.values.toList();
        
    return dataList.map((json) => AppNotification.fromJson(json as Map<String, dynamic>)).toList();
  }

  /// Marks all unread notifications belonging to the user as read.
  ///
  /// Returns a [Map] containing the server confirmation message.
  Future<Map<String, dynamic>> markAllAsRead() async {
    return await apiClient.post('/notifications/mark-all-read');
  }

  /// Marks a specific notification as read.
  ///
  /// [notificationId] The unique string identifier of the notification (usually a UUID).
  /// Returns a [Map] containing the updated notification or success status.
  Future<Map<String, dynamic>> markAsRead(String notificationId) async {
    return await apiClient.patch('/notifications/$notificationId/read');
  }
}