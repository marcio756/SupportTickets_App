import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../viewmodels/team_viewmodel.dart';
import '../../../profile/viewmodels/profile_viewmodel.dart'; 
import '../components/team_member_card.dart';

/// Primary interface for viewing the user's peer group.
/// Dynamically binds to the ProfileViewModel to retrieve context-aware team datasets without hardcoded routes.
class TeamScreen extends StatefulWidget {
  final Widget drawer; 

  const TeamScreen({super.key, required this.drawer});

  @override
  State<TeamScreen> createState() => _TeamScreenState();
}

class _TeamScreenState extends State<TeamScreen> {
  @override
  void initState() {
    super.initState();
    
    /// Defers the network request until the widget tree has settled.
    /// Injects the authenticated user's organization context to fetch the accurate colleague roster.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final profileViewModel = Provider.of<ProfileViewModel>(context, listen: false);
      final teamViewModel = Provider.of<TeamViewModel>(context, listen: false);
      
      final actualTeamId = profileViewModel.teamId;

      if (actualTeamId.isNotEmpty) {
        teamViewModel.loadTeamMembers(actualTeamId);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    // Watches the user's profile state to gracefully degrade the UI if no team assignment exists.
    final profileViewModel = Provider.of<ProfileViewModel>(context);

    return Scaffold(
      appBar: AppBar(
        // Dynamically displays the team name if available, falling back to a generic title.
        title: Text(profileViewModel.teamName.isNotEmpty 
            ? 'My Team: ${profileViewModel.teamName}' 
            : 'My Team'), 
      ),
      drawer: widget.drawer, 
      body: profileViewModel.teamId.isEmpty
          ? const Center(
              child: Padding(
                padding: EdgeInsets.all(24.0),
                child: Text(
                  'You have not been assigned to a team yet. Please ask an administrator to update your profile.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 16, color: Colors.grey),
                ),
              ),
            )
          : Consumer<TeamViewModel>(
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
                        Text('Error: ${viewModel.errorMessage}', textAlign: TextAlign.center),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: () => viewModel.loadTeamMembers(profileViewModel.teamId),
                          child: const Text('Try Again'),
                        ),
                      ],
                    ),
                  );
                }

                if (viewModel.members.isEmpty) {
                  return const Center(child: Text('No colleagues found in this team.'));
                }

                return RefreshIndicator(
                  onRefresh: () => viewModel.loadTeamMembers(profileViewModel.teamId),
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