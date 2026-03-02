import 'package:flutter/material.dart';
import 'dart:convert';
import '../../models/activity_log.dart';

/// Displays the raw properties JSON for a specific log entry.
class ActivityLogDetailsDialog extends StatelessWidget {
  final ActivityLog log;

  const ActivityLogDetailsDialog({super.key, required this.log});

  @override
  Widget build(BuildContext context) {
    // Pretty-print JSON logic
    const JsonEncoder encoder = JsonEncoder.withIndent('  ');
    final String prettyJson = encoder.convert(log.properties);

    return AlertDialog(
      title: const Text('Detalhes do Registo'),
      content: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Ação: ${log.description}', style: const TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text('Tipo: ${log.subjectType ?? 'Desconhecido'}'),
            Text('Utilizador: ${log.causer ?? 'Sistema'}'),
            const SizedBox(height: 16),
            const Text('Propriedades:', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(8),
              ),
              child: SelectableText(
                prettyJson,
                style: const TextStyle(fontFamily: 'monospace', fontSize: 12),
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Fechar'),
        ),
      ],
    );
  }
}