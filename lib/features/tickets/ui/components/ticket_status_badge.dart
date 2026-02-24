import 'package:flutter/material.dart';

/// A visual indicator for the ticket's current status.
/// Applies specific colors and formatting depending on the status string 
/// to ensure immediate visual recognition by the user.
class TicketStatusBadge extends StatelessWidget {
  /// The raw status string provided by the API (e.g., 'open', 'closed').
  final String status;

  const TicketStatusBadge({
    super.key,
    required this.status,
  });

  /// Evaluates the status string and returns a cohesive color palette.
  /// Returns a record containing the background and text color.
  ({Color background, Color text}) _getColorTheme() {
    final lowerStatus = status.toLowerCase();
    if (lowerStatus == 'open') {
      return (background: Colors.green.shade100, text: Colors.green.shade800);
    } else if (lowerStatus == 'closed') {
      return (background: Colors.grey.shade200, text: Colors.grey.shade800);
    } else if (lowerStatus == 'in_progress') {
      return (background: Colors.blue.shade100, text: Colors.blue.shade800);
    }
    
    // Default fallback colors
    return (background: Colors.orange.shade100, text: Colors.orange.shade800);
  }

  @override
  Widget build(BuildContext context) {
    final theme = _getColorTheme();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: theme.background,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(
        status.toUpperCase(),
        style: TextStyle(
          color: theme.text,
          fontSize: 12,
          fontWeight: FontWeight.bold,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}