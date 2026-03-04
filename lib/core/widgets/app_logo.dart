import 'package:flutter/material.dart';

/// AppLogo Widget
/// Standardized logo component to be used in Login, Drawers, and Splash screens.
class AppLogo extends StatelessWidget {
  final double size;

  const AppLogo({
    super.key,
    this.size = 100.0,
  });

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      'assets/images/logo.jpg',
      width: size,
      height: size,
      fit: BoxFit.contain,
      // Error builder to provide a fallback if the image fails to load
      errorBuilder: (context, error, stackTrace) {
        return Icon(Icons.confirmation_number, size: size, color: Colors.blue);
      },
    );
  }
}