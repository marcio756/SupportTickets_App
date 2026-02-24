import '../../../core/network/api_client.dart';
import '../models/app_notification.dart';

/// Repository responsible for handling user notifications.
class NotificationRepository {
  final ApiClient _apiClient;

  /// Initializes the NotificationRepository.
  ///
  /// [_apiClient] The API client used for network requests.
  NotificationRepository(this._apiClient);

  /// Retrieves a list of notifications for the authenticated user.
  ///
  /// Returns a list of [AppNotification] objects.
  Future<List<AppNotification>> getNotifications() async {
    final response = await _apiClient.get('/notifications');
    final List<dynamic> data = response.containsKey('data') ? response['data'] : response;
    
    return data.map((json) => AppNotification.fromJson(json)).toList();
  }

  /// Marks all current notifications as read.
  ///
  /// Returns true if the operation was successful.
  Future<bool> markAllAsRead() async {
    final response = await _apiClient.post('/notifications/mark-all-read');
    return response['status'] == 'Success' || response.containsKey('message');
  }

  /// Marks a specific notification as read.
  ///
  /// [id] The unique string identifier of the notification.
  /// Returns true if the operation was successful.
  Future<bool> markAsRead(String id) async {
    final response = await _apiClient.patch('/notifications/$id/read');
    return response['status'] == 'Success' || response.containsKey('message');
  }
}