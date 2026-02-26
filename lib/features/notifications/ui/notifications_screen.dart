import 'package:flutter/material.dart';
import '../../auth/repositories/auth_repository.dart';
import '../../tickets/repositories/ticket_repository.dart';
import '../../profile/repositories/profile_repository.dart';
import '../repositories/notification_repository.dart';
import '../viewmodels/notifications_viewmodel.dart';
import 'components/grouped_notification_tile.dart';
import '../../tickets/ui/ticket_details_screen.dart';
import '../../../core/widgets/app_drawer.dart';

class NotificationsScreen extends StatefulWidget {
  final AuthRepository authRepository;
  final TicketRepository ticketRepository;
  final ProfileRepository profileRepository;

  const NotificationsScreen({
    super.key,
    required this.authRepository,
    required this.ticketRepository,
    required this.profileRepository,
  });

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  late final NotificationsViewModel _viewModel;
  bool _isNavigating = false;

  @override
  void initState() {
    super.initState();
    _viewModel = NotificationsViewModel(
      repository: NotificationRepository(apiClient: widget.authRepository.apiClient),
    );
    WidgetsBinding.instance.addPostFrameCallback((_) => _viewModel.fetchAndGroupNotifications());
  }

  @override
  void dispose() {
    _viewModel.dispose();
    super.dispose();
  }

  /// Fetches the ticket details before navigating to the TicketDetailsScreen
  Future<void> _navigateToTicket(String ticketIdStr) async {
    if (_isNavigating) return;
    setState(() => _isNavigating = true);

    try {
      final ticketId = int.parse(ticketIdStr);
      final ticket = await widget.ticketRepository.getTicket(ticketId);

      if (mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => TicketDetailsScreen(
              ticket: ticket,
              ticketRepository: widget.ticketRepository,
              profileRepository: widget.profileRepository,
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao abrir ticket: ${e.toString().replaceAll('Exception: ', '')}'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isNavigating = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notificações', style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      drawer: AppDrawer(
        authRepository: widget.authRepository,
        ticketRepository: widget.ticketRepository,
        profileRepository: widget.profileRepository,
        currentRoute: 'Notifications',
      ),
      body: Stack(
        children: [
          ListenableBuilder(
            listenable: _viewModel,
            builder: (context, _) {
              if (_viewModel.isLoading) {
                return const Center(child: CircularProgressIndicator());
              }

              if (_viewModel.errorMessage != null) {
                return Center(child: Text('Erro: ${_viewModel.errorMessage}'));
              }

              if (_viewModel.groupedNotifications.isEmpty) {
                return const Center(child: Text('Não tens notificações.'));
              }

              return ListView.separated(
                itemCount: _viewModel.groupedNotifications.length,
                separatorBuilder: (context, index) => const Divider(height: 1),
                itemBuilder: (context, index) {
                  final group = _viewModel.groupedNotifications[index];
                  return GroupedNotificationTile(
                    notificationGroup: group,
                    onTap: () => _navigateToTicket(group['ticketId']),
                  );
                },
              );
            },
          ),
          if (_isNavigating)
            Container(
              color: Colors.black45,
              child: const Center(child: CircularProgressIndicator()),
            ),
        ],
      ),
    );
  }
}