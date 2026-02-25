import 'package:flutter/material.dart';

/// A reusable dropdown component specifically designed to handle ticket status changes.
class TicketStatusDropdown extends StatelessWidget {
  final String currentStatus;
  final ValueChanged<String> onStatusChanged;
  final bool isLoading;

  /// Initializes the dropdown with the current status and a callback for changes.
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
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.0),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        filled: true,
        fillColor: Colors.grey.shade50,
      ),
      icon: isLoading 
          ? const SizedBox(
              width: 16, 
              height: 16, 
              child: CircularProgressIndicator(strokeWidth: 2)
            ) 
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