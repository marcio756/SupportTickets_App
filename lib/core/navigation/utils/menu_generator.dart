// Ficheiro: lib/core/navigation/utils/menu_generator.dart
import 'package:flutter/material.dart';
import '../models/app_menu_item.dart';

/// Centralizes the Role-Based Access Control (RBAC) logic for UI navigation.
/// Decouples role validation from the widget tree, making it highly testable.
class MenuGenerator {
  static List<AppMenuItem> getItemsForRole(String role) {
    final String normalizedRole = role.toLowerCase();
    final List<AppMenuItem> items = [
      const AppMenuItem(
        title: 'Dashboard',
        icon: Icons.dashboard_outlined,
        routeName: '/dashboard',
      ),
    ];

    if (normalizedRole == 'admin') {
      items.addAll([
        const AppMenuItem(title: 'Team Management', icon: Icons.group_work_outlined, routeName: '/manage-teams'),
        const AppMenuItem(title: 'User Management', icon: Icons.manage_accounts_outlined, routeName: '/manage-users'),
        const AppMenuItem(title: 'Global Vacations', icon: Icons.beach_access_outlined, routeName: '/vacations'),
        const AppMenuItem(title: 'Work Sessions', icon: Icons.timer_outlined, routeName: '/work-sessions'),
      ]);
    } else if (normalizedRole == 'support') {
      items.addAll([
        const AppMenuItem(title: 'My Tickets', icon: Icons.confirmation_number_outlined, routeName: '/tickets'),
        const AppMenuItem(title: 'My Team', icon: Icons.people_outline, routeName: '/my-team'),
        const AppMenuItem(title: 'My Vacations', icon: Icons.beach_access_outlined, routeName: '/vacations'),
        const AppMenuItem(title: 'Time Tracker', icon: Icons.timer_outlined, routeName: '/work-sessions'),
      ]);
    } else if (normalizedRole == 'customer') {
      items.addAll([
        const AppMenuItem(title: 'My Tickets', icon: Icons.support_agent_outlined, routeName: '/my-tickets'),
        const AppMenuItem(title: 'Create Ticket', icon: Icons.add_circle_outline, routeName: '/create-ticket'),
      ]);
    }

    // Common routes for all authenticated users
    items.addAll([
      const AppMenuItem(title: 'Announcements', icon: Icons.campaign_outlined, routeName: '/announcements'),
      const AppMenuItem(title: 'Profile', icon: Icons.person_outline, routeName: '/profile'),
    ]);

    return items;
  }
}