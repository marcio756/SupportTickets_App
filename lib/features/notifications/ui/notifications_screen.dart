import 'package:flutter/material.dart';
import 'components/grouped_notification_tile.dart';
// Note: You will need to import your TicketDetailsScreen to navigate to it when API is ready.

/// Screen displaying all user notifications grouped by ticket.
class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Mock grouped data to simulate API response aggregation
    final List<Map<String, dynamic>> groupedNotifications = [
      {
        'ticketId': '101',
        'newMessagesCount': 3,
        'statusChangesCount': 2,
      },
      {
        'ticketId': '103',
        'newMessagesCount': 2,
        'statusChangesCount': 0,
      },
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Notificações'),
      ),
      body: groupedNotifications.isEmpty
          ? const Center(child: Text('Não tens notificações.'))
          : ListView.separated(
              itemCount: groupedNotifications.length,
              separatorBuilder: (context, index) => const Divider(height: 1),
              itemBuilder: (context, index) {
                final group = groupedNotifications[index];
                return GroupedNotificationTile(
                  notificationGroup: group,
                  onTap: () {
                    // Action pending API integration: Navigate to specific Ticket Details Screen
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('A abrir Ticket #${group['ticketId']}...')),
                    );
                  },
                );
              },
            ),
    );
  }
}