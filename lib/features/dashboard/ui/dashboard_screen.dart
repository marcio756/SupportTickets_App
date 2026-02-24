import 'package:flutter/material.dart';
import '../../auth/repositories/auth_repository.dart';
import '../../auth/ui/login_screen.dart';
import '../../tickets/models/ticket.dart';
import '../../tickets/repositories/ticket_repository.dart';
import '../../tickets/ui/components/ticket_card.dart';
import '../../tickets/ui/ticket_create_screen.dart'; // IMPORT ADICIONADO
import '../../tickets/ui/ticket_details_screen.dart';

/// The main dashboard screen displayed after successful authentication.
class DashboardScreen extends StatefulWidget {
  final AuthRepository authRepository;
  final TicketRepository ticketRepository;

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

  void _loadTickets() {
    setState(() {
      _ticketsFuture = widget.ticketRepository.getTickets();
    });
  }

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
            onPressed: _loadTickets,
          ),
          IconButton(
            icon: const Icon(Icons.logout_rounded),
            onPressed: () => _handleLogout(context),
          ),
        ],
      ),
      body: FutureBuilder<List<Ticket>>(
        future: _ticketsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
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
                    Text(snapshot.error.toString(), textAlign: TextAlign.center),
                    const SizedBox(height: 24),
                    ElevatedButton(onPressed: _loadTickets, child: const Text('Try Again')),
                  ],
                ),
              ),
            );
          }

          final tickets = snapshot.data ?? [];
          if (tickets.isEmpty) {
            return const Center(child: Text('You have no tickets yet.', style: TextStyle(color: Colors.grey)));
          }

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
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => TicketDetailsScreen(
                          ticket: ticket,
                          ticketRepository: widget.ticketRepository,
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
          // Navigation to the creation screen and awaiting the refresh signal
          final bool? shouldRefresh = await Navigator.of(context).push<bool>(
            MaterialPageRoute(
              builder: (_) => TicketCreateScreen(ticketRepository: widget.ticketRepository),
            ),
          );
          
          if (shouldRefresh == true) {
            _loadTickets();
          }
        },
        backgroundColor: Colors.blueAccent,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}