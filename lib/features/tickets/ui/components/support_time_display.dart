import 'package:flutter/material.dart';

/// Displays the total time spent by support agents on this ticket.
class SupportTimeDisplay extends StatelessWidget {
  final String? time;

  const SupportTimeDisplay({super.key, this.time});

  @override
  Widget build(BuildContext context) {
    if (time == null || time == "00:00:00") return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.blueGrey.shade50,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.timer_outlined, size: 14, color: Colors.blueGrey),
          const SizedBox(width: 4),
          Text(
            'Time Spent: $time',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: Colors.blueGrey.shade700,
            ),
          ),
        ],
      ),
    );
  }
}