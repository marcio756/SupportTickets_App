import 'package:flutter/foundation.dart';
import '../models/app_notification.dart';
import '../repositories/notification_repository.dart';

class NotificationsViewModel extends ChangeNotifier {
  final NotificationRepository repository;

  bool _isLoading = false;
  List<Map<String, dynamic>> _groupedNotifications = [];
  String? _errorMessage;

  NotificationsViewModel({required this.repository});

  bool get isLoading => _isLoading;
  List<Map<String, dynamic>> get groupedNotifications => _groupedNotifications;
  String? get errorMessage => _errorMessage;

  Future<void> fetchAndGroupNotifications() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final notifications = await repository.getNotifications();
      _groupNotifications(notifications);
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void _groupNotifications(List<AppNotification> notifications) {
    final Map<String, Map<String, dynamic>> groups = {};

    for (var notif in notifications) {
      // Safely extracting the ticket ID from the data payload
      final String ticketId = notif.data['ticket_id']?.toString() ?? 'Unknown';
      
      if (!groups.containsKey(ticketId)) {
        groups[ticketId] = {
          'ticketId': ticketId,
          'newMessagesCount': 0,
          'statusChangesCount': 0,
          'latestDate': notif.createdAt,
        };
      }

      // Identify type based on Laravel Notification Class names or type strings
      final typeString = notif.type.toLowerCase();
      if (typeString.contains('message')) {
        groups[ticketId]!['newMessagesCount'] = (groups[ticketId]!['newMessagesCount'] as int) + 1;
      } else if (typeString.contains('status')) {
        groups[ticketId]!['statusChangesCount'] = (groups[ticketId]!['statusChangesCount'] as int) + 1;
      }
    }

    _groupedNotifications = groups.values.toList();
    // Sort by latest notification first
    _groupedNotifications.sort((a, b) => (b['latestDate'] as DateTime).compareTo(a['latestDate'] as DateTime));
  }
}