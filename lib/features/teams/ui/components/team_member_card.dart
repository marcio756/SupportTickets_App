import 'package:flutter/material.dart';
import '../../models/team_member.dart';

/// A reusable visual unit representing a team member's identity and schedule.
/// Designed to be decoupled so it can be used in other contexts (e.g., manager dashboards).
class TeamMemberCard extends StatelessWidget {
  final TeamMember member;

  const TeamMemberCard({super.key, required this.member});

  @override
  Widget build(BuildContext context) {
    final shiftDetails = _getShiftPresentation(member.shift);

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        leading: CircleAvatar(
          backgroundColor: Colors.blueAccent.withValues(alpha: 0.1),
          child: Text(
            member.name.substring(0, 1).toUpperCase(),
            style: const TextStyle(color: Colors.blueAccent, fontWeight: FontWeight.bold),
          ),
        ),
        title: Text(member.name, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(member.email, style: const TextStyle(fontSize: 12)),
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(shiftDetails.icon, size: 16, color: shiftDetails.color),
                const SizedBox(width: 4),
                Text(
                  shiftDetails.label,
                  style: TextStyle(color: shiftDetails.color, fontWeight: FontWeight.bold, fontSize: 12),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// Encapsulates the visual mapping logic for shifts.
  _ShiftPresentation _getShiftPresentation(ShiftType shift) {
    switch (shift) {
      case ShiftType.morning:
        return _ShiftPresentation(label: 'Manhã', icon: Icons.wb_sunny, color: Colors.orange);
      case ShiftType.afternoon:
        return _ShiftPresentation(label: 'Tarde', icon: Icons.wb_twilight, color: Colors.deepOrange);
      case ShiftType.night:
        return _ShiftPresentation(label: 'Noite', icon: Icons.nightlight_round, color: Colors.indigo);
      case ShiftType.unknown:
        return _ShiftPresentation(label: 'Não Definido', icon: Icons.help_outline, color: Colors.grey);
    }
  }
}

/// Private utility class to group UI presentation data for shifts.
class _ShiftPresentation {
  final String label;
  final IconData icon;
  final Color color;

  _ShiftPresentation({required this.label, required this.icon, required this.color});
}