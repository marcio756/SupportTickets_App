import 'package:flutter/material.dart';
import '../../models/activity_log.dart';

/// Displays the details of a specific log entry in a user-friendly format.
/// Parses Spatie Activitylog structure (old vs attributes) into visual differences.
class ActivityLogDetailsDialog extends StatelessWidget {
  final ActivityLog log;

  const ActivityLogDetailsDialog({super.key, required this.log});

  /// Formats raw database keys (e.g., 'assigned_to') into readable text ('Assigned To').
  String _formatKey(String key) {
    return key.split('_').map((word) {
      if (word.isEmpty) return '';
      return word[0].toUpperCase() + word.substring(1);
    }).join(' ');
  }

  /// Builds a user-friendly list of property changes instead of raw JSON.
  Widget _buildFriendlyProperties(BuildContext context, Map<String, dynamic> properties) {
    if (properties.isEmpty) {
      return Text('No properties recorded.', 
          style: TextStyle(fontStyle: FontStyle.italic, color: Theme.of(context).colorScheme.onSurfaceVariant));
    }

    // Check for standard Spatie Activitylog 'attributes' and 'old' patterns
    final bool hasAttributes = properties.containsKey('attributes') && properties['attributes'] is Map;
    final bool hasOld = properties.containsKey('old') && properties['old'] is Map;

    if (hasAttributes || hasOld) {
      final Map<String, dynamic> attributes = hasAttributes ? properties['attributes'] : {};
      final Map<String, dynamic> old = hasOld ? properties['old'] : {};
      
      final Set<String> allKeys = {...attributes.keys, ...old.keys};

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: allKeys.map((key) {
          final oldValue = old[key]?.toString() ?? 'Empty';
          final newValue = attributes[key]?.toString() ?? 'Empty';

          // Se for uma criação (sem old value) ou se o valor não mudou, mostra formato simples
          if (!hasOld || oldValue == newValue) {
            return _buildPropertyRow(context, key, newValue);
          }

          // Se houve alteração efetiva, mostra o design de "Antes -> Depois"
          return _buildChangeRow(context, key, oldValue, newValue);
        }).toList(),
      );
    }

    // Fallback for simple key-value pairs if the format is not Spatie standard
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: properties.entries.map((entry) {
        return _buildPropertyRow(context, entry.key, entry.value.toString());
      }).toList(),
    );
  }

  /// Builds a simple property row for static values.
  Widget _buildPropertyRow(BuildContext context, String key, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('${_formatKey(key)}: ', style: const TextStyle(fontWeight: FontWeight.w600)),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }

  /// Builds a visual 'diff' row showing the old and new values.
  Widget _buildChangeRow(BuildContext context, String key, String oldValue, String newValue) {
    final colorScheme = Theme.of(context).colorScheme;
    
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(_formatKey(key), style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: colorScheme.primary)),
          const SizedBox(height: 4),
          Row(
            children: [
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: colorScheme.errorContainer.withValues(alpha: 0.5),
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: colorScheme.errorContainer)
                  ),
                  child: Text(oldValue, style: TextStyle(color: colorScheme.onErrorContainer, fontSize: 13)),
                )
              ),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 8.0),
                child: Icon(Icons.arrow_forward, size: 16),
              ),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: colorScheme.primaryContainer.withValues(alpha: 0.5),
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: colorScheme.primaryContainer)
                  ),
                  child: Text(newValue, style: TextStyle(color: colorScheme.onPrimaryContainer, fontSize: 13, fontWeight: FontWeight.w500)),
                )
              ),
            ],
          ),
          const Divider(height: 16),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Log Details'),
      content: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Action: ${log.description}', style: const TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            Text('Type: ${log.subjectType ?? 'Unknown'}'),
            const SizedBox(height: 4),
            Text('User: ${log.causer ?? 'System'}'),
            const SizedBox(height: 16),
            const Text('Changes:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 12),
            _buildFriendlyProperties(context, log.properties),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Close'),
        ),
      ],
    );
  }
}