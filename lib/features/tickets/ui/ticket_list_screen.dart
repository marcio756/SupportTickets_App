import 'package:flutter/material.dart';
import '../../auth/repositories/auth_repository.dart';
import '../repositories/ticket_repository.dart';
import '../../profile/repositories/profile_repository.dart';
import '../../work_sessions/ui/components/work_session_guard.dart';
import 'components/ticket_card.dart';
import 'components/ticket_card_skeleton.dart';
import '../components/ticket_filters_bottom_sheet.dart';
import 'ticket_create_screen.dart';
import 'ticket_details_screen.dart';
import '../viewmodels/ticket_list_viewmodel.dart';
import '../../../core/widgets/app_drawer.dart';
import '../../../core/widgets/progress_illusion_bar.dart';

class TicketListScreen extends StatefulWidget {
  final AuthRepository authRepository;
  final TicketRepository ticketRepository;
  final ProfileRepository profileRepository;

  const TicketListScreen({
    super.key,
    required this.authRepository,
    required this.ticketRepository,
    required this.profileRepository,
  });

  @override
  State<TicketListScreen> createState() => _TicketListScreenState();
}

class _TicketListScreenState extends State<TicketListScreen> {
  late final TicketListViewModel _viewModel;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _viewModel = TicketListViewModel(ticketRepository: widget.ticketRepository);
    _viewModel.loadTickets(reset: true);
    
    // Setup Infinite Scrolling listener
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    _viewModel.dispose();
    super.dispose();
  }

  /// Triggers pagination load when the user is close to the bottom of the list.
  void _onScroll() {
    if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 200) {
      _viewModel.loadTickets(); // loadTickets now automatically handles next pages
    }
  }

  void _openFilters() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
        child: TicketFiltersBottomSheet(viewModel: _viewModel),
      ),
    ).then((_) {
      // When filters are closed, we refresh the list from page 1
      _viewModel.loadTickets(reset: true);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      drawer: AppDrawer(
        authRepository: widget.authRepository,
        ticketRepository: widget.ticketRepository,
        profileRepository: widget.profileRepository,
        currentRoute: 'Tickets',
      ),
      appBar: AppBar(
        title: const Text('My Tickets', style: TextStyle(fontWeight: FontWeight.bold)),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list_rounded),
            tooltip: 'Filtros',
            onPressed: _openFilters,
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(4.0),
          child: ListenableBuilder(
            listenable: _viewModel,
            builder: (context, _) {
              if (_viewModel.isSyncing || (_viewModel.isLoading && _viewModel.tickets.isNotEmpty)) {
                return ProgressIllusionBar(isComplete: !_viewModel.isSyncing && !_viewModel.isLoading);
              }
              return const SizedBox(height: 4.0);
            },
          ),
        ),
      ),
      body: WorkSessionGuard(
        profileRepository: widget.profileRepository,
        child: ListenableBuilder(
          listenable: _viewModel,
          builder: (context, _) {
            if (_viewModel.errorMessage != null && _viewModel.tickets.isNotEmpty && !_viewModel.isLoadingMore) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(_viewModel.errorMessage!)),
                  );
                  // Clear the error message to avoid infinite snackbars on rebuild
                  _viewModel.clearFilters(); 
                }
              });
            }

            return Column(
              children: [
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
                Expanded(
                  child: _buildContent(),
                ),
              ],
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final bool? shouldRefresh = await Navigator.of(context).push<bool>(
            MaterialPageRoute(
              builder: (_) => TicketCreateScreen(ticketRepository: widget.ticketRepository),
            ),
          );
          if (shouldRefresh == true) {
            _viewModel.loadTickets(reset: true);
          }
        },
        backgroundColor: Theme.of(context).colorScheme.primary,
        child: Icon(Icons.add, color: Theme.of(context).colorScheme.onPrimary),
      ),
    );
  }

  Widget _buildContent() {
    if (_viewModel.isLoading && _viewModel.tickets.isEmpty) {
      return ListView.builder(
        padding: const EdgeInsets.all(16.0),
        itemCount: 5,
        itemBuilder: (context, index) => const TicketCardSkeleton(),
      );
    }

    if (_viewModel.errorMessage != null && _viewModel.tickets.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, size: 60, color: Theme.of(context).colorScheme.error),
              const SizedBox(height: 16),
              const Text('Failed to load tickets', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Text(_viewModel.errorMessage!, textAlign: TextAlign.center),
              const SizedBox(height: 24),
              ElevatedButton(onPressed: () => _viewModel.loadTickets(reset: true), child: const Text('Try Again')),
            ],
          ),
        ),
      );
    }
    
    if (_viewModel.tickets.isEmpty) {
      return Center(
        child: Text(
          'You have no tickets matching the criteria.', 
          style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant)
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _viewModel.syncEmailsAndLoad,
      child: ListView.builder(
        controller: _scrollController,
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16.0),
        // +1 to render the loading indicator at the bottom if hasMore is true
        itemCount: _viewModel.tickets.length + (_viewModel.hasMore ? 1 : 0),
        itemBuilder: (context, index) {
          
          if (index == _viewModel.tickets.length) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 24.0),
                child: _viewModel.isLoadingMore 
                  ? const CircularProgressIndicator()
                  : const SizedBox.shrink(), // Spacer until scroll hits threshold
              ),
            );
          }

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