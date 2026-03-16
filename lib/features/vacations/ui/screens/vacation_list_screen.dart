import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../viewmodels/vacation_viewmodel.dart';
import '../components/vacation_card.dart';
import 'vacation_request_screen.dart';

/// Displays the history of vacations for the authenticated user.
/// Acts as the primary hub for managing personal requests.
class VacationListScreen extends StatefulWidget {
  final String userId;
  final Widget drawer; // Injeção do menu lateral

  const VacationListScreen({super.key, required this.userId, required this.drawer});

  @override
  State<VacationListScreen> createState() => _VacationListScreenState();
}

class _VacationListScreenState extends State<VacationListScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<VacationViewModel>(context, listen: false)
          .loadVacations(widget.userId);
    });
  }

  /// Triggers a dialog confirming the destructive action before mutating state.
  Future<void> _confirmCancellation(String vacationId) async {
    final bool? confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Cancel Request'), // Traduzido
        content: const Text('Are you sure you want to cancel this vacation request?'), // Traduzido
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('No'), // Traduzido
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Yes', style: TextStyle(color: Colors.red)), // Traduzido
          ),
        ],
      ),
    );

    if (confirm == true && mounted) {
      final success = await Provider.of<VacationViewModel>(context, listen: false)
          .cancelRequest(vacationId);
          
      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Request cancelled successfully.')), // Traduzido
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Vacations'), // Traduzido
      ),
      drawer: widget.drawer, // Ativa o botão Hamburger do menu
      body: Consumer<VacationViewModel>(
        builder: (context, viewModel, child) {
          if (viewModel.isLoading && viewModel.vacations.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          if (viewModel.hasError) {
            return Center(child: Text('Error: ${viewModel.errorMessage}')); // Traduzido
          }

          if (viewModel.vacations.isEmpty) {
            return const Center(child: Text('You have no vacation requests yet.')); // Traduzido
          }

          return ListView.builder(
            itemCount: viewModel.vacations.length,
            itemBuilder: (context, index) {
              final vacation = viewModel.vacations[index];
              return VacationCard(
                vacation: vacation,
                onCancel: vacation.id != null 
                    ? () => _confirmCancellation(vacation.id!) 
                    : null,
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => VacationRequestScreen(userId: widget.userId),
            ),
          );
        },
        icon: const Icon(Icons.add),
        label: const Text('New Request'), // Traduzido
      ),
    );
  }
}