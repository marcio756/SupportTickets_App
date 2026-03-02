import 'package:flutter/material.dart';
import '../models/tag.dart';
import '../repositories/tag_repository.dart';
import '../viewmodels/tag_management_viewmodel.dart';
import 'components/tag_form_dialog.dart';

class TagManagementScreen extends StatefulWidget {
  final TagRepository repository;

  const TagManagementScreen({super.key, required this.repository});

  @override
  State<TagManagementScreen> createState() => _TagManagementScreenState();
}

class _TagManagementScreenState extends State<TagManagementScreen> {
  late final TagManagementViewModel _viewModel;

  @override
  void initState() {
    super.initState();
    _viewModel = TagManagementViewModel(repository: widget.repository);
    _viewModel.loadTags();
  }

  @override
  void dispose() {
    _viewModel.dispose();
    super.dispose();
  }

  void _showTagForm([Tag? tag]) {
    showDialog(
      context: context,
      builder: (dialogContext) => TagFormDialog(
        existingTag: tag,
        onSave: (name, color) async {
          final success = tag == null 
              ? await _viewModel.createTag(name, color)
              : await _viewModel.updateTag(tag.id, name, color);
          
          if (!mounted) return; // Fixes async gap warning
          
          if (!success && _viewModel.errorMessage != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(_viewModel.errorMessage!), backgroundColor: Colors.red),
            );
          }
        },
      ),
    );
  }

  void _confirmDelete(Tag tag) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Aviso'),
        content: Text('Tens a certeza que desejas eliminar a tag "${tag.name}"?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(dialogContext), child: const Text('Cancelar')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Theme.of(context).colorScheme.error, foregroundColor: Colors.white),
            onPressed: () async {
              Navigator.pop(dialogContext);
              
              final success = await _viewModel.deleteTag(tag.id);
              
              if (!mounted) return; // Fixes async gap warning
              
              if (!success && _viewModel.errorMessage != null) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(_viewModel.errorMessage!), backgroundColor: Colors.red),
                );
              }
            },
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Gestão de Tags'),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showTagForm(),
        child: const Icon(Icons.add),
      ),
      body: ListenableBuilder(
        listenable: _viewModel,
        builder: (context, _) {
          if (_viewModel.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (_viewModel.tags.isEmpty) {
            return const Center(child: Text('Nenhuma tag encontrada.'));
          }

          return ListView.builder(
            itemCount: _viewModel.tags.length,
            padding: const EdgeInsets.all(16),
            itemBuilder: (context, index) {
              final tag = _viewModel.tags[index];
              return Card(
                margin: const EdgeInsets.only(bottom: 8),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: Theme.of(context).colorScheme.primaryContainer,
                    child: const Icon(Icons.label, size: 18),
                  ),
                  title: Text(tag.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: tag.color != null && tag.color!.isNotEmpty ? Text('Cor: ${tag.color}') : null,
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit, color: Colors.blue),
                        onPressed: () => _showTagForm(tag),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () => _confirmDelete(tag),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        }
      ),
    );
  }
}