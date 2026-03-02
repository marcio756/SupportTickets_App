import 'package:flutter/material.dart';

/// A reusable dialog component to edit and sync the tags associated with a ticket.
class TicketTagsDialog extends StatefulWidget {
  final List<Map<String, dynamic>> availableTags;
  final List<Map<String, dynamic>> currentTags;
  final Function(List<int>) onSave;

  const TicketTagsDialog({
    super.key,
    required this.availableTags,
    required this.currentTags,
    required this.onSave,
  });

  @override
  State<TicketTagsDialog> createState() => _TicketTagsDialogState();
}

class _TicketTagsDialogState extends State<TicketTagsDialog> {
  late Set<int> _selectedTagIds;

  @override
  void initState() {
    super.initState();
    // Pre-populate the local selection state based on the ticket's current tags
    _selectedTagIds = widget.currentTags
        .map((tag) => int.parse(tag['id'].toString()))
        .toSet();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return AlertDialog(
      title: const Text('Gerir Tags'),
      content: SizedBox(
        width: double.maxFinite,
        child: widget.availableTags.isEmpty
            ? const Center(
                child: Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Text('Não existem tags criadas no sistema.'),
                ),
              )
            : ListView.builder(
                shrinkWrap: true,
                itemCount: widget.availableTags.length,
                itemBuilder: (context, index) {
                  final tag = widget.availableTags[index];
                  final int tagId = int.parse(tag['id'].toString());
                  final bool isSelected = _selectedTagIds.contains(tagId);

                  return CheckboxListTile(
                    title: Text(tag['name']?.toString() ?? 'Tag Desconhecida'),
                    value: isSelected,
                    activeColor: colorScheme.primary,
                    onChanged: (bool? value) {
                      setState(() {
                        if (value == true) {
                          _selectedTagIds.add(tagId);
                        } else {
                          _selectedTagIds.remove(tagId);
                        }
                      });
                    },
                  );
                },
              ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancelar'),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: colorScheme.primary,
            foregroundColor: colorScheme.onPrimary,
          ),
          onPressed: () {
            widget.onSave(_selectedTagIds.toList());
            Navigator.of(context).pop();
          },
          child: const Text('Guardar'),
        ),
      ],
    );
  }
}