import 'package:flutter/material.dart';

/// Displays a ranking list of items (e.g., Top Customers, Top Supporters).
/// Extracted to enforce the Single Responsibility Principle and enable reuse across the application.
class RankingCard extends StatelessWidget {
  /// The list of items to display. Expected to be dynamic map structures from the API.
  final List<dynamic> items;
  
  /// Label describing the entity role (e.g., 'Customer', 'Supporter').
  final String roleLabel;
  
  /// The dictionary key used to extract the count value from the item map.
  final String countKey;
  
  /// The display label for the counter.
  final String countLabel;

  const RankingCard({
    super.key,
    required this.items,
    required this.roleLabel,
    required this.countKey,
    required this.countLabel,
  });

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) {
      return const Card(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Text('No data available.'),
        ),
      );
    }

    final theme = Theme.of(context);

    return Card(
      clipBehavior: Clip.antiAlias,
      child: ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: items.length,
        separatorBuilder: (context, index) => const Divider(height: 1),
        itemBuilder: (context, index) {
          final item = items[index];
          return ListTile(
            leading: CircleAvatar(
              backgroundColor: theme.colorScheme.primaryContainer,
              child: Text(
                '#${index + 1}', 
                style: TextStyle(
                  color: theme.colorScheme.onPrimaryContainer, 
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            title: Text(
              item['name']?.toString() ?? 'Unknown', 
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Text(item['email']?.toString() ?? ''),
            trailing: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  item[countKey]?.toString() ?? '0', 
                  style: TextStyle(
                    fontWeight: FontWeight.bold, 
                    fontSize: 16, 
                    color: theme.colorScheme.primary,
                  ),
                ),
                Text(
                  countLabel, 
                  style: const TextStyle(fontSize: 10, color: Colors.grey),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}