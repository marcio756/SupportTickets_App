import 'package:flutter/material.dart';
import '../../auth/repositories/auth_repository.dart';
import '../../profile/repositories/profile_repository.dart';
import '../../tickets/repositories/ticket_repository.dart';
import '../../../core/widgets/app_drawer.dart';
import '../repositories/activity_log_repository.dart';
import '../viewmodels/activity_log_viewmodel.dart';
import 'components/activity_log_details_dialog.dart';

class ActivityLogScreen extends StatefulWidget {
  final ActivityLogRepository repository;
  final AuthRepository authRepository;
  final TicketRepository ticketRepository;
  final ProfileRepository profileRepository;

  const ActivityLogScreen({
    super.key, 
    required this.repository,
    required this.authRepository,
    required this.ticketRepository,
    required this.profileRepository,
  });

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
        title: const Text('Activity Logs'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _viewModel.loadLogs,
          )
        ],
      ),
      drawer: AppDrawer(
        authRepository: widget.authRepository,
        ticketRepository: widget.ticketRepository,
        profileRepository: widget.profileRepository,
        currentRoute: 'Logs',
      ),
      body: ListenableBuilder(
        listenable: _viewModel,
        builder: (context, _) {
          if (_viewModel.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (_viewModel.errorMessage != null) {
            return Center(child: Text('Error: ${_viewModel.errorMessage}', style: TextStyle(color: colorScheme.error)));
          }

          if (_viewModel.logs.isEmpty) {
            return const Center(child: Text('No logs found.'));
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
                subtitle: Text('${log.causer ?? 'System'} • ${log.createdAt.day.toString().padLeft(2, '0')}/${log.createdAt.month.toString().padLeft(2, '0')}/${log.createdAt.year} ${log.createdAt.hour.toString().padLeft(2, '0')}:${log.createdAt.minute.toString().padLeft(2, '0')}'),
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