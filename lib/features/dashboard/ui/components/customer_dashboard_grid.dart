import 'package:flutter/material.dart';
import 'stat_card.dart';

/// Renders the grid of metrics specifically for Customers.
class CustomerDashboardGrid extends StatelessWidget {
  final Map<String, dynamic> metrics;

  const CustomerDashboardGrid({super.key, required this.metrics});

  @override
  Widget build(BuildContext context) {
    final openTickets = metrics['open_tickets']?.toString() ?? '0';
    final resolvedTickets = metrics['resolved_tickets']?.toString() ?? '0';
    
    // Convert remaining seconds to minutes for a cleaner UI
    final remainingSeconds = metrics['remaining_seconds'] is int 
        ? metrics['remaining_seconds'] as int 
        : int.tryParse(metrics['remaining_seconds']?.toString() ?? '0') ?? 0;
        
    final remainingMinutes = (remainingSeconds / 60).ceil().toString();

    return GridView.count(
      crossAxisCount: 2,
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      childAspectRatio: 1.1,
      children: [
        StatCard(
          title: 'Open Tickets',
          value: openTickets,
          icon: Icons.support_agent_outlined,
        ),
        StatCard(
          title: 'Resolved Tickets',
          value: resolvedTickets,
          icon: Icons.task_alt,
          iconBackgroundColor: Colors.greenAccent,
        ),
        StatCard(
          title: 'Time Remaining (Min)',
          value: remainingMinutes,
          icon: Icons.hourglass_bottom,
          iconBackgroundColor: Colors.blueAccent,
        ),
      ],
    );
  }
}