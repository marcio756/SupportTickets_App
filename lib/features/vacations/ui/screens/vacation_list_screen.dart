import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../viewmodels/vacation_viewmodel.dart';
import '../components/vacation_card.dart';
import 'vacation_request_screen.dart';

/// Displays the history of vacations for the authenticated user.
/// Acts as the primary hub for managing personal requests.
class VacationListScreen extends StatefulWidget {
  final String userId;

  const VacationListScreen({super.key, required this.userId});

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
        title: const Text('Cancelar Pedido'),
        content: const Text('Tem a certeza que pretende cancelar este pedido de férias?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Não'),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Sim', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirm == true && mounted) {
      final success = await Provider.of<VacationViewModel>(context, listen: false)
          .cancelRequest(vacationId);
          
      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Pedido cancelado com sucesso.')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('As Minhas Férias'),
      ),
      body: Consumer<VacationViewModel>(
        builder: (context, viewModel, child) {
          if (viewModel.isLoading && viewModel.vacations.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          if (viewModel.hasError) {
            return Center(child: Text('Erro: ${viewModel.errorMessage}'));
          }

          if (viewModel.vacations.isEmpty) {
            return const Center(child: Text('Ainda não tem pedidos de férias.'));
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
        label: const Text('Novo Pedido'),
      ),
    );
  }
}