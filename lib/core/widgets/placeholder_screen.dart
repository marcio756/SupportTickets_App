import 'package:flutter/material.dart';

/// A generic screen used as a placeholder for unimplemented features.
/// It accepts the drawer so navigation remains seamless.
class PlaceholderScreen extends StatelessWidget {
  final String title;
  final Widget drawer;

  /// Initializes the PlaceholderScreen.
  const PlaceholderScreen({
    super.key,
    required this.title,
    required this.drawer,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        elevation: 1,
      ),
      drawer: drawer,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.construction, size: 64, color: Colors.grey.shade400),
            const SizedBox(height: 16),
            Text(
              '$title\nEm desenvolvimento',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 18, color: Colors.grey.shade600),
            ),
          ],
        ),
      ),
    );
  }
}