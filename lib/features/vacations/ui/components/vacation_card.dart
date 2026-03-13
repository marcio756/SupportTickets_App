import 'package:flutter/material.dart';
import '../../models/vacation_request.dart';
import 'package:intl/intl.dart';

/// A reusable visual component representing a single vacation record.
/// Can be consumed by the user history view or a manager's approval queue.
class VacationCard extends StatelessWidget {
  final VacationRequest vacation;
  final VoidCallback? onCancel;

  const VacationCard({
    super.key,
    required this.vacation,
    this.onCancel,
  });

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('dd/MM/yyyy');
    final color = _getStatusColor(vacation.status);

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16.0),
        leading: CircleAvatar(
          backgroundColor: color.withValues(alpha: 0.2),
          child: Icon(Icons.beach_access, color: color),
        ),
        title: Text('${dateFormat.format(vacation.startDate)} - ${dateFormat.format(vacation.endDate)}'),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Total Days: ${vacation.totalDays}'),
              const SizedBox(height: 4),
              Chip(
                label: Text(vacation.status.name.toUpperCase()),
                backgroundColor: color.withValues(alpha: 0.1),
                labelStyle: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 12),
              ),
            ],
          ),
        ),
        trailing: (vacation.status == VacationStatus.pending && onCancel != null)
            ? IconButton(
                icon: const Icon(Icons.cancel_outlined, color: Colors.redAccent),
                onPressed: onCancel,
                tooltip: 'Cancelar Pedido',
              )
            : null,
      ),
    );
  }

  Color _getStatusColor(VacationStatus status) {
    switch (status) {
      case VacationStatus.approved:
        return Colors.green;
      case VacationStatus.rejected:
        return Colors.red;
      case VacationStatus.pending:
        return Colors.orange;
    }
  }
}