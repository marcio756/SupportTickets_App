import 'package:flutter/material.dart';
import '../../repositories/activity_log_repository.dart';
import '../../viewmodels/activity_log_viewmodel.dart';
import 'activity_log_details_dialog.dart';

class ActivityLogScreen extends StatefulWidget {
  final ActivityLogRepository repository;

  const ActivityLogScreen({super.key, required this.repository});

  @override
  State<ActivityLogScreen> createState() => _ActivityLogScreenState();
}

class _ActivityLogScreenState extends State<ActivityLogScreen> {
  late final ActivityLogViewModel _viewModel;

  @override
  void initState() {
    super.initState();
    _viewModel = ActivityLogViewModel(repository: widget.repository);
    _viewModel.loadLogs();
  }

  @override
  void dispose() {
    _viewModel.dispose();
    super.dispose();
  }

  IconData _getEventIcon(String event) {
    switch (event.toLowerCase()) {
      case 'created': return Icons.add_circle_outline;
      case 'updated': return Icons.edit_note;
      case 'deleted': return Icons.delete_outline;
      default: return Icons.info_outline;
    }
  }

  Color _getEventColor(String event, ColorScheme scheme) {
    switch (event.toLowerCase()) {
      case 'created': return Colors.green;
      case 'updated': return Colors.blue;
      case 'deleted': return scheme.error;
      default: return scheme.onSurfaceVariant;
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Logs de Atividade'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _viewModel.loadLogs,
          )
        ],
      ),
      body: ListenableBuilder(
        listenable: _viewModel,
        builder: (context, _) {
          if (_viewModel.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (_viewModel.errorMessage != null) {
            return Center(child: Text('Erro: ${_viewModel.errorMessage}', style: TextStyle(color: colorScheme.error)));
          }

          if (_viewModel.logs.isEmpty) {
            return const Center(child: Text('Nenhum registo encontrado.'));
          }

          return ListView.separated(
            itemCount: _viewModel.logs.length,
            separatorBuilder: (context, index) => const Divider(height: 1),
            itemBuilder: (context, index) {
              final log = _viewModel.logs[index];
              return ListTile(
                leading: CircleAvatar(
                  backgroundColor: colorScheme.surfaceContainerHighest,
                  child: Icon(_getEventIcon(log.event), color: _getEventColor(log.event, colorScheme)),
                ),
                title: Text(log.description),
                subtitle: Text('${log.causer ?? 'Sistema'} • ${log.createdAt.day}/${log.createdAt.month}/${log.createdAt.year} ${log.createdAt.hour}:${log.createdAt.minute.toString().padLeft(2, '0')}'),
                trailing: const Icon(Icons.chevron_right, size: 16),
                onTap: () {
                  showDialog(
                    context: context,
                    builder: (context) => ActivityLogDetailsDialog(log: log),
                  );
                },
              );
            },
          );
        }
      ),
    );
  }
}