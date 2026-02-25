import 'package:flutter/material.dart';

class TicketStatusDropdown extends StatelessWidget {
  final String currentStatus;
  final ValueChanged<String> onStatusChanged;
  final bool isLoading;

  const TicketStatusDropdown({
    super.key,
    required this.currentStatus,
    required this.onStatusChanged,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<String>(
      initialValue: currentStatus,
      decoration: InputDecoration(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.0),
          borderSide: BorderSide(color: Theme.of(context).colorScheme.outline),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.0),
          borderSide: BorderSide(color: Theme.of(context).colorScheme.outlineVariant),
        ),
        filled: true,
        fillColor: Theme.of(context).colorScheme.surfaceContainerHighest,
      ),
      icon: isLoading 
          ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2)) 
          : const Icon(Icons.arrow_drop_down),
      items: const [
        DropdownMenuItem(value: 'open', child: Text('Open')),
        DropdownMenuItem(value: 'in_progress', child: Text('In Progress')),
        DropdownMenuItem(value: 'resolved', child: Text('Resolved')),
        DropdownMenuItem(value: 'closed', child: Text('Closed')),
      ],
      onChanged: isLoading ? null : (value) {
        if (value != null && value != currentStatus) {
          onStatusChanged(value);
        }
      },
    );
  }
}