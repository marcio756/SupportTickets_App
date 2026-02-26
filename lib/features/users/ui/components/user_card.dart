import 'package:flutter/material.dart';

/// A card displaying user information for the User Management screen.
/// Includes action buttons to edit or delete a user.
class UserCard extends StatelessWidget {
  final Map<String, dynamic> userMock;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const UserCard({
    super.key,
    required this.userMock,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final bool isSupport = userMock['role'] == 'support';
    final colorScheme = Theme.of(context).colorScheme;

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: CircleAvatar(
          backgroundColor: isSupport ? colorScheme.primary : colorScheme.tertiary,
          child: Icon(
            isSupport ? Icons.support_agent : Icons.person,
            color: colorScheme.onPrimary,
          ),
        ),
        title: Text(
          userMock['name'],
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(userMock['email']),
            const SizedBox(height: 4),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: isSupport 
                    ? colorScheme.primaryContainer 
                    : colorScheme.tertiaryContainer,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                userMock['role'].toString().toUpperCase(),
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: isSupport 
                      ? colorScheme.onPrimaryContainer 
                      : colorScheme.onTertiaryContainer,
                ),
              ),
            ),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.edit_outlined),
              color: colorScheme.primary,
              tooltip: 'Edit User',
              onPressed: onEdit,
            ),
            IconButton(
              icon: const Icon(Icons.delete_outline),
              color: colorScheme.error,
              tooltip: 'Delete User',
              onPressed: onDelete,
            ),
          ],
        ),
      ),
    );
  }
}