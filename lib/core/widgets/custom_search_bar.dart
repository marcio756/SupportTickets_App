import 'package:flutter/material.dart';

/// A reusable search bar component with a standardized design.
/// Ensures visual consistency and reduces boilerplate across list screens.
class CustomSearchBar extends StatelessWidget {
  /// The placeholder text shown when the input is empty.
  final String hintText;
  
  /// Callback triggered when the user submits the search query.
  final ValueChanged<String> onSubmitted;

  const CustomSearchBar({
    super.key,
    this.hintText = 'Search...',
    required this.onSubmitted,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Container(
      color: theme.scaffoldBackgroundColor,
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: TextField(
        decoration: InputDecoration(
          hintText: hintText,
          prefixIcon: const Icon(Icons.search),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(30),
            borderSide: BorderSide.none,
          ),
          filled: true,
          fillColor: theme.colorScheme.surfaceContainerHighest,
          contentPadding: const EdgeInsets.symmetric(vertical: 0),
        ),
        onSubmitted: onSubmitted,
      ),
    );
  }
}