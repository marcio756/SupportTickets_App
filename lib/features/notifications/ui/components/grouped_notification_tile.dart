import 'package:flutter/material.dart';

/// A tile component displaying grouped notifications for a specific ticket.
class GroupedNotificationTile extends StatelessWidget {
  final Map<String, dynamic> notificationGroup;
  final VoidCallback onTap;

  const GroupedNotificationTile({
    super.key,
    required this.notificationGroup,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final int msgCount = notificationGroup['newMessagesCount'] ?? 0;
    final int statusCount = notificationGroup['statusChangesCount'] ?? 0;
    
    // Build the descriptive text based on groupings
    final List<String> descriptions = [];
    if (msgCount > 0) descriptions.add('Mensagem nova x$msgCount');
    if (statusCount > 0) descriptions.add('Mudou o estado x$statusCount');

    return ListTile(
      leading: CircleAvatar(
        backgroundColor: Theme.of(context).colorScheme.primaryContainer,
        child: Icon(
          Icons.notifications,
          color: Theme.of(context).colorScheme.primary,
        ),
      ),
      title: Text(
        'Ticket #${notificationGroup['ticketId']}',
        style: const TextStyle(fontWeight: FontWeight.bold),
      ),
      subtitle: Text(descriptions.join(', ')),
      trailing: const Icon(Icons.chevron_right),
      onTap: onTap,
    );
  }
}