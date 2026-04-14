import 'package:flutter/material.dart';

/// A primary call-to-action button standardized for the entire application.
/// It dynamically uses the application theme colors to support Light/Dark mode seamlessly.
class PrimaryButton extends StatelessWidget {
  /// The label displayed on the button.
  final String text;
  
  /// The callback fired when the button is tapped.
  final VoidCallback onPressed;
  
  /// Indicates whether the button should display a loading indicator.
  final bool isLoading;

  const PrimaryButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    // Extracting theme ensures the component stays agnostic and dynamically 
    // adapts to the application's global design rules.
    final theme = Theme.of(context);

    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: theme.colorScheme.primary,
          foregroundColor: theme.colorScheme.onPrimary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          elevation: 0,
        ),
        child: isLoading
            ? SizedBox(
                height: 24,
                width: 24,
                child: CircularProgressIndicator(
                  color: theme.colorScheme.onPrimary,
                  strokeWidth: 2,
                ),
              )
            : Text(
                text,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
      ),
    );
  }
}