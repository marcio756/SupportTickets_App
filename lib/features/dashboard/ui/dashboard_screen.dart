import 'package:flutter/material.dart';
import '../../../core/widgets/app_drawer.dart';
import '../../auth/repositories/auth_repository.dart';
import '../../tickets/repositories/ticket_repository.dart';
import '../../profile/repositories/profile_repository.dart';
import 'components/stat_card.dart';

/// The main dashboard screen displaying key metrics and statistics.
/// The layout adapts based on the user's role (Support vs Customer).
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
  // Mock property to toggle UI design before API implementation.
  // Set to true to see the Support view, false to see the Customer view.
  final bool _isSupportRole = true; 

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
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Overview',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            _buildStatGrid(context),
            if (_isSupportRole) ...[
              const SizedBox(height: 32),
              Text(
                'Top Clients (By Tickets)',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              _buildTopClientsList(context),
            ]
          ],
        ),
      ),
    );
  }

  /// Builds the grid of metric cards depending on the user role.
  Widget _buildStatGrid(BuildContext context) {
    return GridView.count(
      crossAxisCount: 2,
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      childAspectRatio: 1.1,
      children: _isSupportRole
          ? const [
              StatCard(
                title: 'Global Active Tickets',
                value: '42',
                icon: Icons.confirmation_number_outlined,
              ),
              StatCard(
                title: 'Resolved (All Time)',
                value: '1,204',
                icon: Icons.check_circle_outline,
                iconBackgroundColor: Colors.greenAccent,
              ),
              StatCard(
                title: 'Time Spent Today (Hrs)',
                value: '5.2',
                icon: Icons.timer_outlined,
                iconBackgroundColor: Colors.orangeAccent,
              ),
            ]
          : const [
              StatCard(
                title: 'Open Tickets',
                value: '3',
                icon: Icons.support_agent_outlined,
              ),
              StatCard(
                title: 'Resolved Tickets',
                value: '15',
                icon: Icons.task_alt,
                iconBackgroundColor: Colors.greenAccent,
              ),
              StatCard(
                title: 'Time Remaining (Min)',
                value: '120',
                icon: Icons.hourglass_bottom,
                iconBackgroundColor: Colors.blueAccent,
              ),
            ],
    );
  }

  /// Builds a mockup list of top clients for the support view.
  Widget _buildTopClientsList(BuildContext context) {
    // Mock data for UI design
    final List<Map<String, dynamic>> topClients = [
      {'name': 'Acme Corp', 'tickets': 150, 'avatar': 'A'},
      {'name': 'Globex Inc', 'tickets': 120, 'avatar': 'G'},
      {'name': 'Initech', 'tickets': 85, 'avatar': 'I'},
      {'name': 'Umbrella Corp', 'tickets': 64, 'avatar': 'U'},
      {'name': 'Soylent', 'tickets': 42, 'avatar': 'S'},
    ];

    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: topClients.length,
      separatorBuilder: (context, index) => const Divider(),
      itemBuilder: (context, index) {
        final client = topClients[index];
        return ListTile(
          leading: CircleAvatar(
            backgroundColor: Theme.of(context).colorScheme.secondaryContainer,
            child: Text(client['avatar'], style: TextStyle(color: Theme.of(context).colorScheme.onSecondaryContainer)),
          ),
          title: Text(client['name'], style: const TextStyle(fontWeight: FontWeight.bold)),
          trailing: Chip(
            label: Text('${client['tickets']} Tickets'),
            backgroundColor: Theme.of(context).colorScheme.surfaceContainerHighest,
          ),
        );
      },
    );
  }
}