import 'package:flutter/material.dart';

/// A standardized error state placeholder for lists and screens.
/// Centralizes error UI to maintain a consistent user experience.
class ErrorPlaceholder extends StatelessWidget {
  /// The main error title.
  final String title;
  
  /// The detailed error message, usually coming from a ViewModel.
  final String message;
  
  /// Action to be executed to retry the failed operation.
  final VoidCallback onRetry;

  const ErrorPlaceholder({
    super.key,
    this.title = 'An error occurred',
    required this.message,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 60, color: theme.colorScheme.error),
            const SizedBox(height: 16),
            Text(
              title, 
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(message, textAlign: TextAlign.center),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: onRetry,
              child: const Text('Try Again'),
            ),
          ],
        ),
      ),
    );
  }
}