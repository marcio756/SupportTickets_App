import 'package:flutter/material.dart';

/// Represents a single navigable item within the application's sidebar.
class AppMenuItem {
  final String title;
  final IconData icon;
  final String routeName;

  const AppMenuItem({
    required this.title,
    required this.icon,
    required this.routeName,
  });
}