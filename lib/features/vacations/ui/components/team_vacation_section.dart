import 'package:flutter/material.dart';
import 'package:supporttickets_app/features/vacations/models/vacation_models.dart';
import 'package:supporttickets_app/features/vacations/ui/components/member_vacation_card.dart';

class TeamVacationSection extends StatelessWidget {
  final VacationTeam team;

  // Corrigido para super.key
  const TeamVacationSection({
    super.key,
    required this.team,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16.0, 24.0, 16.0, 8.0),
          child: Row(
            children: [
              Icon(Icons.groups, color: Theme.of(context).primaryColor),
              const SizedBox(width: 8.0),
              Text(
                '${team.name} (${team.shift})',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).primaryColor,
                    ),
              ),
            ],
          ),
        ),
        if (team.members.isEmpty)
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.0),
            child: Text('No members assigned to this team.'),
          )
        else
          // Removido o .toList() desnecessário
          ...team.members.map((member) => MemberVacationCard(member: member)),
      ],
    );
  }
}