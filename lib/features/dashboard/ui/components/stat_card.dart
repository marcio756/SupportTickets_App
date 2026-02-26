import 'package:flutter/material.dart';

/// A reusable card component to display statistical data on the dashboard.
/// Refactored to be completely overflow-proof using FittedBox and Expanded.
class StatCard extends StatelessWidget {
  /// The title of the statistic.
  final String title;

  /// The numerical or textual value to display.
  final String value;

  /// The icon representing the statistic.
  final IconData icon;

  /// Optional background color for the icon container.
  final Color? iconBackgroundColor;

  const StatCard({
    super.key,
    required this.title,
    required this.value,
    required this.icon,
    this.iconBackgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: iconBackgroundColor ?? colorScheme.primaryContainer,
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                color: colorScheme.onPrimaryContainer,
                size: 20, // Slightly reduced to prevent overflow on very small devices
              ),
            ),
            const SizedBox(height: 8),
            // FittedBox guarantees the text shrinks instead of overflowing
            FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerLeft,
              child: Text(
                value,
                style: theme.textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: colorScheme.onSurface,
                ),
              ),
            ),
            const SizedBox(height: 4),
            // Expanded forces the text to stay inside the card's constraints
            Expanded(
              child: Text(
                title,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}