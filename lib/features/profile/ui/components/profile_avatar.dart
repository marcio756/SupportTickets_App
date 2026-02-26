import 'package:flutter/material.dart';

/// Visual component responsible for displaying the user's avatar.
class ProfileAvatar extends StatelessWidget {
  final String name;

  const ProfileAvatar({super.key, required this.name});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final initial = name.isNotEmpty ? name[0].toUpperCase() : 'U';

    return Center(
      child: CircleAvatar(
        radius: 50,
        backgroundColor: colorScheme.primary,
        child: Text(
          initial,
          style: TextStyle(fontSize: 40, color: colorScheme.onPrimary),
        ),
      ),
    );
  }
}