import 'package:flutter/material.dart';
import '../../auth/repositories/auth_repository.dart';
import '../../auth/ui/login_screen.dart';
import '../../tickets/repositories/ticket_repository.dart';
import '../../profile/repositories/profile_repository.dart';
import '../../tickets/ui/components/ticket_card.dart';
import '../../tickets/ui/ticket_create_screen.dart';
import '../../tickets/ui/ticket_details_screen.dart';
import '../../tickets/viewmodels/ticket_list_viewmodel.dart';

/// The main dashboard screen displayed after successful authentication.
/// It acts purely as a UI layer, observing the [TicketListViewModel] for state changes.
class DashboardScreen extends StatefulWidget {
  final AuthRepository authRepository;
  final TicketRepository ticketRepository;
  final ProfileRepository profileRepository;

  const DashboardScreen({
    super.key,
    required this.authRepository,
    required this.ticketRepository,
    required this.profileRepository,
  });

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  // The ViewModel instance responsible for this screen's business logic
  late final TicketListViewModel _viewModel;

  @override
  void initState() {
    super.initState();
    // Initialize the ViewModel and trigger the initial data fetch
    _viewModel = TicketListViewModel(ticketRepository: widget.ticketRepository);
    _viewModel.loadTickets();
  }

  @override
  void dispose() {
    // Dispose the ViewModel to prevent memory leaks
    _viewModel.dispose();
    super.dispose();
  }

  /// Handles the user logout process and navigation robustly.
  Future<void> _handleLogout(BuildContext context) async {
    try {
      // Attempt to invalidate session on the server
      await widget.authRepository.logout();
    } catch (e) {
      // Silent catch: If the API fails (no network, timeout, CORS), 
      // we don't care. The AuthRepository already deleted the token locally 
      // in its 'finally' block. We just need to route the user out.
      debugPrint('API Logout failed, forcing local logout: $e');
    } finally {
      // Always route to login safely
      if (context.mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (_) => LoginScreen(
              authRepository: widget.authRepository,
              ticketRepository: widget.ticketRepository,
              profileRepository: widget.profileRepository,
            ),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: const Text('My Tickets', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 1,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _viewModel.loadTickets,
          ),
          IconButton(
            icon: const Icon(Icons.logout_rounded),
            onPressed: () => _handleLogout(context),
          ),
        ],
      ),
      // ListenableBuilder listens to the ViewModel and rebuilds the UI when notifyListeners() is called
      body: ListenableBuilder(
        listenable: _viewModel,
        builder: (context, _) {
          if (_viewModel.isLoading && _viewModel.tickets.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          if (_viewModel.errorMessage != null && _viewModel.tickets.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.error_outline, size: 60, color: Colors.redAccent),
                    const SizedBox(height: 16),
                    const Text('Failed to load tickets', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    Text(_viewModel.errorMessage!, textAlign: TextAlign.center),
                    const SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: _viewModel.loadTickets, 
                      child: const Text('Try Again')
                    ),
                  ],
                ),
              ),
            );
          }

          if (_viewModel.tickets.isEmpty) {
            return const Center(
              child: Text('You have no tickets yet.', style: TextStyle(color: Colors.grey))
            );
          }

          return RefreshIndicator(
            onRefresh: _viewModel.loadTickets,
            child: ListView.builder(
              padding: const EdgeInsets.all(16.0),
              itemCount: _viewModel.tickets.length,
              itemBuilder: (context, index) {
                final ticket = _viewModel.tickets[index];
                return TicketCard(
                  ticket: ticket,
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => TicketDetailsScreen(
                          ticket: ticket,
                          ticketRepository: widget.ticketRepository,
                          profileRepository: widget.profileRepository,
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final bool? shouldRefresh = await Navigator.of(context).push<bool>(
            MaterialPageRoute(
              builder: (_) => TicketCreateScreen(ticketRepository: widget.ticketRepository),
            ),
          );
          
          if (shouldRefresh == true) {
            _viewModel.loadTickets();
          }
        },
        backgroundColor: Colors.blueAccent,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}