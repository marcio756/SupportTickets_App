import 'package:flutter/material.dart';
import '../../../core/widgets/app_drawer.dart';
import '../../../core/services/firebase_messaging_service.dart'; // Importação do nosso serviço singleton
import '../../auth/repositories/auth_repository.dart';
import '../../tickets/repositories/ticket_repository.dart';
import '../../profile/repositories/profile_repository.dart';
import '../repositories/dashboard_repository.dart';
import '../viewmodels/dashboard_viewmodel.dart';
import 'components/support_dashboard_grid.dart';
import 'components/customer_dashboard_grid.dart';
import 'components/top_clients_list.dart';

/// The main dashboard screen displaying key metrics and statistics.
/// The layout automatically adapts based on the user's role defined by the API.
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
  late final DashboardViewModel _viewModel;

  @override
  void initState() {
    super.initState();
    _viewModel = DashboardViewModel(
      dashboardRepository: DashboardRepository(apiClient: widget.authRepository.apiClient),
    );
    
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _viewModel.loadDashboardData();
      
      // Initialize Firebase Push Notifications and request permission.
      // We pass the active ApiClient so the service can register the token with the Laravel backend.
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
        title: const Text('Dashboard', style: TextStyle(fontWeight: FontWeight.bold)),
        elevation: 0,
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
          if (_viewModel.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (_viewModel.errorMessage != null) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.error_outline, size: 48, color: Theme.of(context).colorScheme.error),
                    const SizedBox(height: 16),
                    Text(
                      'Failed to load dashboard',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _viewModel.errorMessage!,
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant),
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton.icon(
                      onPressed: _viewModel.loadDashboardData,
                      icon: const Icon(Icons.refresh),
                      label: const Text('Retry'),
                    ),
                  ],
                ),
              ),
            );
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Overview',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                
                _viewModel.isSupportRole 
                    ? SupportDashboardGrid(metrics: _viewModel.metrics)
                    : CustomerDashboardGrid(metrics: _viewModel.metrics),

                if (_viewModel.isSupportRole) ...[
                  const SizedBox(height: 32),
                  Text(
                    'Top 5 Clients (By Tickets)',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  TopClientsList(clients: _viewModel.topClients),
                ]
              ],
            ),
          );
        },
      ),
    );
  }
}