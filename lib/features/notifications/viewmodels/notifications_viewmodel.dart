import 'package:flutter/foundation.dart';
import '../models/app_notification.dart';
import '../repositories/notification_repository.dart';

/// ViewModel responsible for managing the state and business logic of notifications.
class NotificationsViewModel extends ChangeNotifier {
  /// The repository used to interact with notification data.
  final NotificationRepository repository;

  bool _isLoading = false;
  List<Map<String, dynamic>> _groupedNotifications = [];
  String? _errorMessage;

  /// Creates a new instance of [NotificationsViewModel].
  NotificationsViewModel({required this.repository});

  /// Indicates whether a network request is currently active.
  bool get isLoading => _isLoading;

  /// Gets the list of parsed, unread, and grouped notifications.
  List<Map<String, dynamic>> get groupedNotifications => _groupedNotifications;

  /// Gets the current error message, if any.
  String? get errorMessage => _errorMessage;

  /// Fetches notifications from the repository and processes them into groups.
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

  /// Groups unread notifications by their associated ticket ID.
  void _groupNotifications(List<AppNotification> notifications) {
    final Map<String, Map<String, dynamic>> groups = {};

    // Filter out already read notifications so they disappear from the UI
    final unreadNotifications = notifications.where((n) => !n.isRead).toList();

    for (var notif in unreadNotifications) {
      final String ticketId = notif.data['ticket_id']?.toString() ?? 'Unknown';
      
      // Match the exact key 'title' sent by the Laravel backend
      final String ticketTitle = notif.data['title']?.toString() ?? 'Ticket #$ticketId';
      
      if (!groups.containsKey(ticketId)) {
        groups[ticketId] = {
          'ticketId': ticketId,
          'ticketTitle': ticketTitle,
          'newMessagesCount': 0,
          'statusChangesCount': 0,
          'latestDate': notif.createdAt,
          'notificationIds': <String>[],
        };
      }

      // Aggregate the notification IDs to mark them all as read later
      (groups[ticketId]!['notificationIds'] as List<String>).add(notif.id);

      // Extract the event type from the data payload (e.g., 'new_message', 'status_change')
      final payloadType = notif.data['type']?.toString().toLowerCase() ?? '';
      final payloadMessage = notif.data['message']?.toString().toLowerCase() ?? '';
      
      // Determine the category of the notification
      final bool isMessage = payloadType.contains('message') || 
                             payloadMessage.contains('mensagem');
                             
      final bool isStatus = payloadType.contains('status') || 
                            payloadMessage.contains('estado');

      if (isMessage) {
        groups[ticketId]!['newMessagesCount'] = (groups[ticketId]!['newMessagesCount'] as int) + 1;
      } else if (isStatus) {
        groups[ticketId]!['statusChangesCount'] = (groups[ticketId]!['statusChangesCount'] as int) + 1;
      } else {
        // Fallback: If unknown, count as a message so it doesn't render empty
        groups[ticketId]!['newMessagesCount'] = (groups[ticketId]!['newMessagesCount'] as int) + 1;
      }
    }

    _groupedNotifications = groups.values.toList();
    // Sort by latest notification first
    _groupedNotifications.sort((a, b) => (b['latestDate'] as DateTime).compareTo(a['latestDate'] as DateTime));
  }

  /// Marks a specific group of notifications as read with Optimistic UI updates.
  Future<void> markGroupAsRead(List<String> notificationIds) async {
    try {
      // Optimistic Update: Instantly remove the tapped notification group from the screen
      _groupedNotifications.removeWhere((group) {
        final groupIds = group['notificationIds'] as List<String>;
        return groupIds.any((id) => notificationIds.contains(id));
      });
      notifyListeners();

      // Proceed to mark them as read on the backend
      for (String id in notificationIds) {
        await repository.markAsRead(id);
      }
      
      // Perform a silent background refresh to ensure sync with the server
      final notifications = await repository.getNotifications();
      _groupNotifications(notifications);
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
    }
  }
}