import 'package:flutter/material.dart';
import 'stat_card.dart';

/// Renders the grid of metrics specifically for Support Agents.
class SupportDashboardGrid extends StatelessWidget {
  final Map<String, dynamic> metrics;

  const SupportDashboardGrid({super.key, required this.metrics});

  @override
  Widget build(BuildContext context) {
    final activeTickets = metrics['active_tickets']?.toString() ?? '0';
    final resolvedTickets = metrics['resolved_tickets']?.toString() ?? '0';
    
    // Parses the time spent, ensuring it displays nicely as a decimal for hours
    final timeSpentRaw = metrics['time_spent_today'] ?? 0;
    final timeSpentFormatted = (timeSpentRaw is num) 
        ? timeSpentRaw.toStringAsFixed(1) 
        : timeSpentRaw.toString();

    return GridView.count(
      crossAxisCount: 2,
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      childAspectRatio: 1.1,
      children: [
        StatCard(
          title: 'Global Active Tickets',
          value: activeTickets,
          icon: Icons.confirmation_number_outlined,
        ),
        StatCard(
          title: 'Resolved (All Time)',
          value: resolvedTickets,
          icon: Icons.check_circle_outline,
          iconBackgroundColor: Colors.greenAccent,
        ),
        StatCard(
          title: 'Time Spent Today (Hrs)',
          value: timeSpentFormatted,
          icon: Icons.timer_outlined,
          iconBackgroundColor: Colors.orangeAccent,
        ),
      ],
    );
  }
}