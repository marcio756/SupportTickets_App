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
import '../../../core/widgets/custom_search_bar.dart';
import '../../../core/widgets/error_placeholder.dart';

/// Screen displaying a paginated list of tickets with search and filter capabilities.
/// Implements infinite scrolling and work session protection.
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
      _viewModel.loadTickets(); 
    }
  }

  /// Opens the filter bottom sheet and refreshes data on close.
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
            // Handle error feedback for background operations when the list already has data
            if (_viewModel.errorMessage != null && _viewModel.tickets.isNotEmpty && !_viewModel.isLoadingMore) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(_viewModel.errorMessage!)),
                  );
                  _viewModel.clearFilters(); 
                }
              });
            }

            return Column(
              children: [
                CustomSearchBar(
                  hintText: 'Search tickets...',
                  onSubmitted: (value) => _viewModel.setSearchQuery(value),
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

  /// Renders the list content based on the ViewModel state.
  Widget _buildContent() {
    if (_viewModel.isLoading && _viewModel.tickets.isEmpty) {
      return ListView.builder(
        padding: const EdgeInsets.all(16.0),
        itemCount: 5,
        itemBuilder: (context, index) => const TicketCardSkeleton(),
      );
    }

    if (_viewModel.errorMessage != null && _viewModel.tickets.isEmpty) {
      return ErrorPlaceholder(
        title: 'Failed to load tickets',
        message: _viewModel.errorMessage!,
        onRetry: () => _viewModel.loadTickets(reset: true),
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
        itemCount: _viewModel.tickets.length + (_viewModel.hasMore ? 1 : 0),
        itemBuilder: (context, index) {
          if (index == _viewModel.tickets.length) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 24.0),
                child: _viewModel.isLoadingMore 
                  ? const CircularProgressIndicator()
                  : const SizedBox.shrink(),
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