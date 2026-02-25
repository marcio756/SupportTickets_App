import 'package:flutter/material.dart';

/// A reusable component to display the remaining support time of a ticket.
class SupportTimeDisplay extends StatelessWidget {
  final String? supportTime;

  /// Initializes the display with the provided time string (e.g., "01:30:00").
  const SupportTimeDisplay({super.key, required this.supportTime});

  @override
  Widget build(BuildContext context) {
    if (supportTime == null || supportTime!.isEmpty) {
      return const SizedBox.shrink();
    }

    // Visual feedback if time is low (e.g., less than 10 minutes '00:0X:XX')
    final bool isLowTime = supportTime!.startsWith('00:0');

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: isLowTime ? Colors.red.shade50 : Colors.grey.shade100,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: isLowTime ? Colors.red.shade200 : Colors.grey.shade300),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.timer_outlined,
            size: 16,
            color: isLowTime ? Colors.red.shade700 : Colors.grey.shade700,
          ),
          const SizedBox(width: 4),
          Text(
            supportTime!,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: isLowTime ? Colors.red.shade700 : Colors.grey.shade800,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }
}