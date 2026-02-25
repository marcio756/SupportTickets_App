import 'package:flutter/material.dart';

/// A reusable component to display the remaining support time of a ticket.
class SupportTimeDisplay extends StatelessWidget {
  final String? supportTime;

  const SupportTimeDisplay({super.key, required this.supportTime});

  @override
  Widget build(BuildContext context) {
    if (supportTime == null || supportTime!.isEmpty) {
      return const SizedBox.shrink();
    }

    final bool isLowTime = supportTime!.startsWith('00:0');
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: isLowTime 
            ? (isDark ? Colors.red.shade900.withValues(alpha: 0.4) : Colors.red.shade50)
            : Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isLowTime 
              ? (isDark ? Colors.redAccent : Colors.red.shade200)
              : Theme.of(context).colorScheme.outlineVariant
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.timer_outlined,
            size: 16,
            color: isLowTime 
                ? (isDark ? Colors.redAccent.shade100 : Colors.red.shade700) 
                : Theme.of(context).colorScheme.onSurfaceVariant,
          ),
          const SizedBox(width: 4),
          Text(
            supportTime!,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: isLowTime 
                  ? (isDark ? Colors.redAccent.shade100 : Colors.red.shade800)
                  : Theme.of(context).colorScheme.onSurfaceVariant,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }
}