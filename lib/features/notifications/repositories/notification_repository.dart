import '../../../core/network/api_client.dart';
import '../models/app_notification.dart';

class NotificationRepository {
  final ApiClient apiClient;

  NotificationRepository({required this.apiClient});

  Future<List<AppNotification>> getNotifications() async {
    final Map<String, dynamic> response = await apiClient.get('/notifications');
    
    List<dynamic> rawList = [];

    // Tenta encontrar a chave 'data' (Laravel Pagination ou Resource)
    if (response.containsKey('data') && response['data'] != null) {
      final dynamic dataField = response['data'];
      if (dataField is List) {
        rawList = dataField;
      } else if (dataField is Map) {
        rawList = dataField.values.toList();
      }
    } else {
      // Caso a resposta seja um objeto JSON em que as chaves são UUIDs soltos
      response.forEach((key, value) {
        if (key != 'current_page' && key != 'total' && key != 'links' && value is Map) {
          rawList.add(value);
        }
      });
    }

    final List<AppNotification> notifications = [];
    
    for (var item in rawList) {
      if (item is Map) {
        // Converte cada notificação usando o model 100% seguro que criámos acima
        notifications.add(AppNotification.fromJson(Map<String, dynamic>.from(item)));
      }
    }

    return notifications;
  }

  Future<void> markAsRead(String notificationId) async {
    await apiClient.patch('/notifications/$notificationId/read');
  }

  Future<void> markAllAsRead() async {
    await apiClient.post('/notifications/mark-all-read');
  }
}