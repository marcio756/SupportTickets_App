import 'package:flutter/material.dart';

/// Representa um item de navegação dinâmico do menu lateral.
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