import '../../../core/network/api_client.dart';

/// Repository responsible for handling user notifications.
class NotificationRepository {
  final ApiClient _apiClient;

  /// Initializes the NotificationRepository.
  ///
  /// [_apiClient] The API client used for network requests.
  NotificationRepository(this._apiClient);

  /// Retrieves a list of notifications for the authenticated user.
  ///
  /// Returns a Map containing the notifications list.
  Future<Map<String, dynamic>> getNotifications() async {
    return await _apiClient.get('/notifications');
  }

  /// Marks all current notifications as read.
  ///
  /// Returns a Map confirming the action.
  Future<Map<String, dynamic>> markAllAsRead() async {
    return await _apiClient.post('/notifications/mark-all-read');
  }

  /// Marks a specific notification as read.
  ///
  /// [id] The unique identifier of the notification.
  /// Returns a Map confirming the action.
  Future<Map<String, dynamic>> markAsRead(int id) async {
    return await _apiClient.patch('/notifications/$id/read');
  }
}