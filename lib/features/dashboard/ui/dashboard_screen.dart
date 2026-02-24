import 'package:flutter/material.dart';
import '../../auth/repositories/auth_repository.dart';
import '../../auth/ui/login_screen.dart';
import '../../tickets/models/ticket.dart';
import '../../tickets/repositories/ticket_repository.dart';
import '../../tickets/ui/components/ticket_card.dart';

/// The main dashboard screen displayed after successful authentication.
/// Retrieves and displays the user's tickets while providing global app navigation.
class DashboardScreen extends StatefulWidget {
  final AuthRepository authRepository;
  final TicketRepository ticketRepository;

  /// Initializes the dashboard with required dependencies.
  const DashboardScreen({
    super.key,
    required this.authRepository,
    required this.ticketRepository,
  });

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  late Future<List<Ticket>> _ticketsFuture;

  @override
  void initState() {
    super.initState();
    _loadTickets();
  }

  /// Initiates the network request to fetch the list of tickets.
  void _loadTickets() {
    setState(() {
      _ticketsFuture = widget.ticketRepository.getTickets();
    });
  }

  /// Handles the logout process and routes the user back to the login screen.
  Future<void> _handleLogout(BuildContext context) async {
    await widget.authRepository.logout();
    
    if (context.mounted) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (_) => LoginScreen(
            authRepository: widget.authRepository,
            ticketRepository: widget.ticketRepository,
          ),
        ),
      );
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
            tooltip: 'Refresh Tickets',
            onPressed: _loadTickets,
          ),
          IconButton(
            icon: const Icon(Icons.logout_rounded),
            tooltip: 'Logout',
            onPressed: () => _handleLogout(context),
          ),
        ],
      ),
      body: FutureBuilder<List<Ticket>>(
        future: _ticketsFuture,
        builder: (context, snapshot) {
          // Display loading state while the network request is in flight
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          // Handle potential network or parsing errors
          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.error_outline, size: 60, color: Colors.redAccent),
                    const SizedBox(height: 16),
                    Text(
                      'Failed to load tickets',
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      snapshot.error.toString(),
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.grey.shade600),
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: _loadTickets,
                      child: const Text('Try Again'),
                    )
                  ],
                ),
              ),
            );
          }

          final tickets = snapshot.data ?? [];

          // Handle the empty state when the user has no tickets
          if (tickets.isEmpty) {
            return const Center(
              child: Text(
                'You have no tickets yet.',
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
            );
          }

          // Render the populated list of tickets
          return RefreshIndicator(
            onRefresh: () async => _loadTickets(),
            child: ListView.builder(
              padding: const EdgeInsets.all(16.0),
              itemCount: tickets.length,
              itemBuilder: (context, index) {
                final ticket = tickets[index];
                return TicketCard(
                  ticket: ticket,
                  onTap: () {
                    // Placeholder for routing to Ticket Details Screen in the future
                    debugPrint('Tapped on ticket: ${ticket.id}');
                  },
                );
              },
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Placeholder for the "Create Ticket" modal/screen
        },
        backgroundColor: Colors.blueAccent,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}