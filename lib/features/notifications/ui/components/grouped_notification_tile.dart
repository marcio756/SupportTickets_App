import 'package:flutter/material.dart';

/// A UI component that displays a grouped summary of notifications for a specific ticket.
/// 
/// Follows the Single Responsibility Principle by only handling the presentation
/// of the grouped notification data and delegating interactions via callbacks.
class GroupedNotificationTile extends StatelessWidget {
  /// The grouped notification data map.
  final Map<String, dynamic> groupData;

  /// Callback executed when the tile is tapped.
  final VoidCallback onTap;

  /// Creates a new instance of [GroupedNotificationTile].
  const GroupedNotificationTile({
    super.key,
    required this.groupData,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final int messagesCount = groupData['newMessagesCount'] as int;
    final int statusCount = groupData['statusChangesCount'] as int;
    final String ticketTitle = groupData['ticketTitle'] as String;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildIcon(messagesCount, statusCount),
              const SizedBox(width: 16.0),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      ticketTitle,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16.0,
                      ),
                    ),
                    const SizedBox(height: 6.0),
                    if (messagesCount > 0)
                      Text(
                        'Recebeu uma mensagem (x$messagesCount)',
                        style: TextStyle(color: Colors.grey.shade700, fontSize: 14.0),
                      ),
                    if (statusCount > 0)
                      Text(
                        'Mudança de estado (x$statusCount)',
                        style: TextStyle(color: Colors.grey.shade700, fontSize: 14.0),
                      ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right, color: Colors.grey),
            ],
          ),
        ),
      ),
    );
  }

  /// Builds the leading icon based on the notification types present.
  Widget _buildIcon(int messagesCount, int statusCount) {
    IconData iconData = Icons.notifications;
    Color iconColor = Colors.blue;

    if (messagesCount > 0 && statusCount == 0) {
      iconData = Icons.chat_bubble_outline;
      iconColor = Colors.green;
    } else if (statusCount > 0 && messagesCount == 0) {
      iconData = Icons.info_outline;
      iconColor = Colors.orange;
    }

    return CircleAvatar(
      backgroundColor: iconColor.withValues(alpha: 0.1),
      radius: 24,
      child: Icon(iconData, color: iconColor, size: 24),
    );
  }
}