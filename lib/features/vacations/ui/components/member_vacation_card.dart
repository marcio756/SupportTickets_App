import 'package:flutter/material.dart';
import 'package:supporttickets_app/features/vacations/models/vacation_models.dart';

class MemberVacationCard extends StatelessWidget {
  final VacationMember member;

  // Corrigido para super.key
  const MemberVacationCard({
    super.key,
    required this.member,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  member.name,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                _buildSummaryBadge(context),
              ],
            ),
            const SizedBox(height: 12.0),
            if (member.vacations.isEmpty)
              Text(
                'No vacations booked for this year.',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.grey,
                    ),
              )
            else
              // Removido o .toList() desnecessário no final
              ...member.vacations.map((vacation) => _buildVacationRow(context, vacation)),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryBadge(BuildContext context) {
    final bool isWarning = member.summary.remainingDays <= 5;
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
      decoration: BoxDecoration(
        // Substituído withOpacity por withValues (novo standard do Flutter)
        color: isWarning 
            ? Colors.orange.withValues(alpha: 0.1) 
            : Colors.green.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12.0),
      ),
      child: Text(
        '${member.summary.usedDays} / ${member.summary.totalAllowed} days',
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: isWarning ? Colors.orange[800] : Colors.green[800],
              fontWeight: FontWeight.bold,
            ),
      ),
    );
  }

  Widget _buildVacationRow(BuildContext context, Vacation vacation) {
    final statusColor = vacation.status == 'approved' ? Colors.green : Colors.orange;
    
    final startDateStr = '${vacation.startDate.day}/${vacation.startDate.month}';
    final endDateStr = '${vacation.endDate.day}/${vacation.endDate.month}';

    return Padding(
      padding: const EdgeInsets.only(top: 8.0),
      child: Row(
        children: [
          Icon(Icons.event_seat, size: 16.0, color: statusColor),
          const SizedBox(width: 8.0),
          Text(
            '$startDateStr to $endDateStr',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const Spacer(),
          Text(
            '${vacation.totalDays} days',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
        ],
      ),
    );
  }
}