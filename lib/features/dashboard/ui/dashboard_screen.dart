import 'package:flutter/material.dart';
import '../../../core/widgets/app_drawer.dart';
import '../../../core/services/firebase_messaging_service.dart';
import '../../auth/repositories/auth_repository.dart';
import '../../tickets/repositories/ticket_repository.dart';
import '../../profile/repositories/profile_repository.dart';
import '../repositories/dashboard_repository.dart';
import '../viewmodels/dashboard_viewmodel.dart';
import 'components/stat_card.dart';

/// Main Dashboard Screen that dynamically displays content based on Role
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
  late DashboardViewModel _viewModel;

  @override
  void initState() {
    super.initState();
    _viewModel = DashboardViewModel(
      repository: DashboardRepository(apiClient: widget.authRepository.apiClient),
    );
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _viewModel.loadDashboardData();
      FirebaseMessagingService().init(context, widget.authRepository.apiClient);
    });
  }

  @override
  void dispose() {
    _viewModel.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => _viewModel.loadDashboardData(),
          ),
        ],
      ),
      drawer: AppDrawer(
        authRepository: widget.authRepository,
        ticketRepository: widget.ticketRepository,
        profileRepository: widget.profileRepository,
        currentRoute: 'Dashboard',
      ),
      body: ListenableBuilder(
        listenable: _viewModel,
        builder: (context, _) {
          if (_viewModel.isLoading && _viewModel.stats.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          if (_viewModel.errorMessage != null) {
            return Center(
              child: Text(
                _viewModel.errorMessage!,
                style: TextStyle(color: Theme.of(context).colorScheme.error),
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: _viewModel.loadDashboardData,
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(16.0),
              child: _buildRoleBasedDashboard(context),
            ),
          );
        },
      ),
    );
  }

  /// Delegates the rendering logic to the specific role builder
  Widget _buildRoleBasedDashboard(BuildContext context) {
    switch (_viewModel.role) {
      case 'admin':
        return _buildAdminDashboard(context);
      case 'supporter':
        return _buildSupporterDashboard(context);
      case 'customer':
      default:
        return _buildCustomerDashboard(context);
    }
  }

  /// Builds the Dashboard specifically designed for Administrators
  Widget _buildAdminDashboard(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Expanded(child: StatCard(title: 'Open Tickets', value: _viewModel.stats['open_tickets']?.toString() ?? '0', icon: Icons.pending_actions_rounded)),
            const SizedBox(width: 16),
            Expanded(child: StatCard(title: 'Resolved Tickets', value: _viewModel.stats['resolved_tickets']?.toString() ?? '0', icon: Icons.check_circle_outline_rounded)),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(child: StatCard(title: 'Total Customers', value: _viewModel.stats['total_customers']?.toString() ?? '0', icon: Icons.people_outline_rounded)),
            const SizedBox(width: 16),
            const Expanded(child: SizedBox()), // Placeholder for alignment symmetry 
          ],
        ),
        
        const SizedBox(height: 32),
        Text('Top Customers', style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
        const SizedBox(height: 12),
        _buildRankingCard(_viewModel.topCustomers, 'Customer', 'tickets_count', 'Tickets Created'),
        
        const SizedBox(height: 32),
        Text('Top Supporters', style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
        const SizedBox(height: 12),
        _buildRankingCard(_viewModel.topSupporters, 'Supporter', 'resolved_count', 'Tickets Resolved'),
      ],
    );
  }

  /// Builds the Dashboard specifically designed for Supporters
  Widget _buildSupporterDashboard(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Expanded(child: StatCard(title: 'All Open', value: _viewModel.stats['open_tickets']?.toString() ?? '0', icon: Icons.inbox_rounded)),
            const SizedBox(width: 16),
            Expanded(child: StatCard(title: 'My Tickets', value: _viewModel.stats['my_tickets']?.toString() ?? '0', icon: Icons.assignment_ind_rounded)),
          ],
        ),
        const SizedBox(height: 16),
        StatCard(title: 'Resolved Today', value: _viewModel.stats['resolved_today']?.toString() ?? '0', icon: Icons.task_alt_rounded),
        
        const SizedBox(height: 32),
        Text('Top Customers', style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
        const SizedBox(height: 12),
        _buildRankingCard(_viewModel.topCustomers, 'Customer', 'tickets_count', 'Tickets Created'),
      ],
    );
  }

  /// Builds the Dashboard specifically designed for Customers
  Widget _buildCustomerDashboard(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Expanded(child: StatCard(title: 'My Open Tickets', value: _viewModel.stats['my_open_tickets']?.toString() ?? '0', icon: Icons.pending_actions_rounded)),
            const SizedBox(width: 16),
            Expanded(child: StatCard(title: 'Total Tickets', value: _viewModel.stats['my_total_tickets']?.toString() ?? '0', icon: Icons.confirmation_number_rounded)),
          ],
        ),
      ],
    );
  }

  /// Reusable widget to render a leaderboard/ranking card (SRP)
  Widget _buildRankingCard(List<dynamic> items, String roleLabel, String countKey, String countLabel) {
    if (items.isEmpty) {
      return const Card(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Text('No data available.'),
        ),
      );
    }
    return Card(
      clipBehavior: Clip.antiAlias,
      child: ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: items.length,
        separatorBuilder: (context, index) => const Divider(height: 1),
        itemBuilder: (context, index) {
          final item = items[index];
          return ListTile(
            leading: CircleAvatar(
              backgroundColor: Theme.of(context).colorScheme.primaryContainer,
              child: Text('#${index + 1}', style: TextStyle(color: Theme.of(context).colorScheme.onPrimaryContainer, fontWeight: FontWeight.bold)),
            ),
            title: Text(item['name']?.toString() ?? 'Unknown', style: const TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Text(item['email']?.toString() ?? ''),
            trailing: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(item[countKey]?.toString() ?? '0', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Theme.of(context).colorScheme.primary)),
                Text(countLabel, style: const TextStyle(fontSize: 10, color: Colors.grey)),
              ],
            ),
          );
        },
      ),
    );
  }
}