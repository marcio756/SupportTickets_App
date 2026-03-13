import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../viewmodels/team_viewmodel.dart';
import '../components/team_member_card.dart';

/// Primary interface for viewing the user's peer group.
/// Binds to the TeamViewModel to display a reactive list of colleagues.
class TeamScreen extends StatefulWidget {
  final String teamId;

  const TeamScreen({super.key, required this.teamId});

  @override
  State<TeamScreen> createState() => _TeamScreenState();
}

class _TeamScreenState extends State<TeamScreen> {
  @override
  void initState() {
    super.initState();
    // Safely trigger data fetching after the widget is mounted in the tree.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<TeamViewModel>(context, listen: false).loadTeamMembers(widget.teamId);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('A Minha Equipa'),
      ),
      body: Consumer<TeamViewModel>(
        builder: (context, viewModel, child) {
          if (viewModel.isLoading && viewModel.members.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          if (viewModel.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, color: Colors.red, size: 48),
                  const SizedBox(height: 16),
                  Text('Erro: ${viewModel.errorMessage}', textAlign: TextAlign.center),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => viewModel.loadTeamMembers(widget.teamId),
                    child: const Text('Tentar Novamente'),
                  ),
                ],
              ),
            );
          }

          if (viewModel.members.isEmpty) {
            return const Center(child: Text('Não existem membros associados a esta equipa.'));
          }

          return RefreshIndicator(
            onRefresh: () => viewModel.loadTeamMembers(widget.teamId),
            child: ListView.builder(
              itemCount: viewModel.members.length,
              itemBuilder: (context, index) {
                final member = viewModel.members[index];
                return TeamMemberCard(member: member);
              },
            ),
          );
        },
      ),
    );
  }
}