import 'package:flutter/material.dart';

/// Component responsible for rendering the list of top clients by ticket volume.
class TopClientsList extends StatelessWidget {
  final List<Map<String, dynamic>> clients;

  const TopClientsList({super.key, required this.clients});

  @override
  Widget build(BuildContext context) {
    if (clients.isEmpty) {
      return Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: const Padding(
          padding: EdgeInsets.all(24.0),
          child: Center(
            child: Text('No client data available.'),
          ),
        ),
      );
    }

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      clipBehavior: Clip.antiAlias,
      child: ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: clients.length,
        separatorBuilder: (context, index) => const Divider(height: 1),
        itemBuilder: (context, index) {
          final client = clients[index];
          final String name = client['name'] ?? 'Unknown Client';
          final String ticketsCount = client['tickets_count']?.toString() ?? '0';
          final String initial = name.isNotEmpty ? name[0].toUpperCase() : '?';

          return ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            leading: CircleAvatar(
              backgroundColor: Theme.of(context).colorScheme.secondaryContainer,
              child: Text(
                initial, 
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onSecondaryContainer,
                  fontWeight: FontWeight.bold,
                )
              ),
            ),
            title: Text(
              name, 
              style: const TextStyle(fontWeight: FontWeight.bold)
            ),
            subtitle: Text(client['email'] ?? ''),
            trailing: Chip(
              label: Text(
                '$ticketsCount Tickets',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              backgroundColor: Theme.of(context).colorScheme.surfaceContainerHighest,
              side: BorderSide.none,
            ),
          );
        },
      ),
    );
  }
}