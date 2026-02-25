import 'package:flutter/material.dart';
import '../../auth/repositories/auth_repository.dart';
import '../../tickets/repositories/ticket_repository.dart';
import '../../profile/repositories/profile_repository.dart';
import '../../tickets/ui/components/ticket_card.dart';
import '../../tickets/components/ticket_filters_bottom_sheet.dart';
import '../../tickets/ui/ticket_create_screen.dart';
import '../../tickets/ui/ticket_details_screen.dart';
import '../../tickets/viewmodels/ticket_list_viewmodel.dart';
import '../../../core/widgets/app_drawer.dart';
import '../../../core/widgets/placeholder_screen.dart';

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

  /// Opens the filter bottom sheet.
  void _openFilters() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
        child: TicketFiltersBottomSheet(viewModel: _viewModel),
      ),
    );
  }

  /// Navigates to the generic Notifications screen.
  void _openNotifications() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => PlaceholderScreen(
          title: 'Notificações',
          drawer: AppDrawer(
            authRepository: widget.authRepository,
            ticketRepository: widget.ticketRepository,
            profileRepository: widget.profileRepository,
            currentRoute: '', // Emptied because Notifications overlay is an extra route
          ),
        )
      )
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: AppDrawer(
        authRepository: widget.authRepository,
        ticketRepository: widget.ticketRepository,
        profileRepository: widget.profileRepository,
        currentRoute: 'Tickets', // Highlights 'Tickets' in the Sidebar
      ),
      appBar: AppBar(
        title: const Text('My Tickets', style: TextStyle(fontWeight: FontWeight.bold)),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_none_rounded),
            tooltip: 'Notificações',
            onPressed: _openNotifications,
          ),
          IconButton(
            icon: const Icon(Icons.filter_list_rounded),
            tooltip: 'Filtros',
            onPressed: _openFilters,
          ),
        ],
      ),
      body: ListenableBuilder(
        listenable: _viewModel,
        builder: (context, _) {
          return Column(
            children: [
              // Search Bar
              Container(
                color: Theme.of(context).scaffoldBackgroundColor,
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                child: TextField(
                  decoration: InputDecoration(
                    hintText: 'Search tickets...',
                    prefixIcon: const Icon(Icons.search),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30),
                      borderSide: BorderSide.none,
                    ),
                    filled: true,
                    fillColor: Theme.of(context).colorScheme.surfaceContainerHighest,
                    contentPadding: const EdgeInsets.symmetric(vertical: 0),
                  ),
                  onSubmitted: (value) => _viewModel.setSearchQuery(value),
                ),
              ),

              // Content Area
              Expanded(
                child: _buildContent(),
              ),
            ],
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

  /// Builds the main content area based on the view model state.
  Widget _buildContent() {
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
        child: Text('You have no tickets matching the criteria.', style: TextStyle(color: Colors.grey))
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
  }
}