import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../viewmodels/team_viewmodel.dart';
import '../../models/team.dart';

/// Provides CRUD capabilities for administrators to manage teams and shift assignments.
class AdminTeamManagementScreen extends StatefulWidget {
  final Widget drawer;

  const AdminTeamManagementScreen({super.key, required this.drawer});

  @override
  State<AdminTeamManagementScreen> createState() => _AdminTeamManagementScreenState();
}

class _AdminTeamManagementScreenState extends State<AdminTeamManagementScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<TeamViewModel>(context, listen: false).loadAllTeams();
    });
  }

  // --- MÉTODOS DE CREATE / EDIT / DELETE (MANTIDOS IGUAIS AO ANTERIOR) ---
  void _showTeamDialog(TeamViewModel viewModel, {Team? team}) {
    final isEditing = team != null;
    final nameController = TextEditingController(text: team?.name);
    String selectedShift = team?.shift ?? 'morning';

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(isEditing ? 'Edit Team' : 'Create New Team'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(controller: nameController, decoration: const InputDecoration(labelText: 'Team Name')),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                initialValue: selectedShift,
                decoration: const InputDecoration(labelText: 'Assigned Shift'),
                items: const [
                  DropdownMenuItem(value: 'morning', child: Text('Morning')),
                  DropdownMenuItem(value: 'afternoon', child: Text('Afternoon')),
                  DropdownMenuItem(value: 'night', child: Text('Night')),
                ],
                onChanged: (value) { if (value != null) selectedShift = value; },
              ),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
            ElevatedButton(
              onPressed: () async {
                final name = nameController.text.trim();
                if (name.isEmpty) return;
                final success = isEditing 
                    ? await viewModel.updateTeam(team.id, name, selectedShift)
                    : await viewModel.createTeam(name, selectedShift);
                if (context.mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(success ? 'Success.' : 'Operation failed.'), backgroundColor: success ? Colors.green : Colors.red),
                  );
                }
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }

  void _confirmDelete(BuildContext context, TeamViewModel viewModel, Team team) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Team'),
        content: Text('Are you sure you want to delete "${team.name}"?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          TextButton(
            onPressed: () async {
              Navigator.pop(ctx);
              final success = await viewModel.deleteTeam(team.id);
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(success ? 'Deleted.' : 'Failed.'), backgroundColor: success ? Colors.green : Colors.red));
              }
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  // --- NOVO: MÉTODO DE ASSOCIAÇÃO DE MEMBROS ---
  /// Triggers a modal dialog to batch assign or unassign supporters to the selected team.
  void _showAssignMembersDialog(BuildContext context, TeamViewModel viewModel, Team team) async {
    showDialog(
      context: context, 
      barrierDismissible: false,
      builder: (_) => const Center(child: CircularProgressIndicator()),
    );

    // Orchestrates sequential fetching: Get all global supporters, then current team members
    final allSupporters = await viewModel.fetchAllSupporters();
    await viewModel.loadTeamMembers(team.id);
    final currentMembers = viewModel.members.map((m) => m.id).toSet();
    
    if (context.mounted) {
      Navigator.pop(context); // Dismiss loading
      
      List<String> selectedIds = List.from(currentMembers);

      showDialog(
        context: context,
        builder: (ctx) {
          return StatefulBuilder(
            builder: (context, setState) {
              return AlertDialog(
                title: Text('Assign Members to ${team.name}'),
                content: SizedBox(
                  width: double.maxFinite,
                  child: allSupporters.isEmpty
                      ? const Text('No supporters available in the system.')
                      : ListView.builder(
                          shrinkWrap: true,
                          itemCount: allSupporters.length,
                          itemBuilder: (context, index) {
                            final supporter = allSupporters[index];
                            final isSelected = selectedIds.contains(supporter.id);
                            
                            return CheckboxListTile(
                              title: Text(supporter.name),
                              subtitle: Text(supporter.email),
                              value: isSelected,
                              activeColor: Colors.blueAccent,
                              onChanged: (bool? checked) {
                                setState(() {
                                  if (checked == true) {
                                    selectedIds.add(supporter.id);
                                  } else {
                                    selectedIds.remove(supporter.id);
                                  }
                                });
                              },
                            );
                          },
                        ),
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(ctx),
                    child: const Text('Cancel'),
                  ),
                  ElevatedButton(
                    onPressed: () async {
                      Navigator.pop(ctx);
                      final success = await viewModel.assignTeamMembers(team.id, selectedIds);
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(success ? 'Roster updated successfully.' : 'Failed to update roster.'),
                            backgroundColor: success ? Colors.green : Colors.red,
                          ),
                        );
                      }
                    },
                    child: const Text('Save Assignments'),
                  ),
                ],
              );
            }
          );
        }
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Team Management')),
      drawer: widget.drawer,
      body: Consumer<TeamViewModel>(
        builder: (context, viewModel, child) {
          if (viewModel.isLoading && viewModel.teams.isEmpty) return const Center(child: CircularProgressIndicator());
          if (viewModel.hasError) return Center(child: Text('Error: ${viewModel.errorMessage}'));

          return ListView.builder(
            itemCount: viewModel.teams.length,
            itemBuilder: (context, index) {
              final team = viewModel.teams[index];
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: ListTile(
                  leading: const Icon(Icons.group, color: Colors.blue),
                  title: Text(team.name),
                  subtitle: Text('Shift: ${team.shift.toUpperCase()}'),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Botão Novo: Assign Members
                      IconButton(
                        icon: const Icon(Icons.person_add_alt_1, color: Colors.green),
                        tooltip: 'Assign Members',
                        onPressed: () => _showAssignMembersDialog(context, viewModel, team),
                      ),
                      IconButton(
                        icon: const Icon(Icons.edit, color: Colors.orange),
                        tooltip: 'Edit Team',
                        onPressed: () => _showTeamDialog(viewModel, team: team),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        tooltip: 'Delete Team',
                        onPressed: () => _confirmDelete(context, viewModel, team),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: Consumer<TeamViewModel>(
        builder: (context, viewModel, child) => FloatingActionButton(
          onPressed: () => _showTeamDialog(viewModel),
          child: const Icon(Icons.add),
        ),
      ),
    );
  }
}