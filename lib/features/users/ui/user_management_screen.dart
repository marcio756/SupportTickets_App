import 'dart:async';
import 'package:flutter/material.dart';
import '../../../core/widgets/app_drawer.dart';
import '../../auth/repositories/auth_repository.dart';
import '../../tickets/repositories/ticket_repository.dart';
import '../../profile/repositories/profile_repository.dart';
import '../repositories/user_repository.dart';
import '../viewmodels/user_management_viewmodel.dart';
import 'components/user_card.dart';
import 'components/user_form_dialog.dart';

class UserManagementScreen extends StatefulWidget {
  final AuthRepository authRepository;
  final TicketRepository ticketRepository;
  final ProfileRepository profileRepository;

  const UserManagementScreen({
    super.key,
    required this.authRepository,
    required this.ticketRepository,
    required this.profileRepository,
  });

  @override
  State<UserManagementScreen> createState() => _UserManagementScreenState();
}

class _UserManagementScreenState extends State<UserManagementScreen> {
  late final UserManagementViewModel _viewModel;
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    _viewModel = UserManagementViewModel(
      userRepository: UserRepository(apiClient: widget.authRepository.apiClient),
    );
    WidgetsBinding.instance.addPostFrameCallback((_) => _viewModel.fetchUsers());
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _viewModel.dispose();
    super.dispose();
  }

  void _onSearchChanged(String query) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      _viewModel.setSearchQuery(query);
    });
  }

  void _showUserForm([Map<String, dynamic>? user]) {
    showDialog(
      context: context,
      builder: (_) => UserFormDialog(
        userMock: user,
        onSave: (data) async {
          final success = await _viewModel.saveUser(id: user?['id']?.toString(), data: data);
          if (mounted && success) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(user == null ? 'User created!' : 'User updated!')),
            );
          } else if (mounted && _viewModel.errorMessage != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Error: ${_viewModel.errorMessage}', style: TextStyle(color: Theme.of(context).colorScheme.onError)), backgroundColor: Theme.of(context).colorScheme.error),
            );
          }
        },
      ),
    );
  }

  void _confirmDelete(String id) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Delete User'),
        content: const Text('Are you sure you want to delete this user?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Theme.of(context).colorScheme.error, foregroundColor: Theme.of(context).colorScheme.onError),
            onPressed: () async {
              Navigator.pop(context);
              final success = await _viewModel.deleteUser(id);
              if (mounted && success) {
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('User deleted!')));
              } else if (mounted && _viewModel.errorMessage != null) {
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: ${_viewModel.errorMessage}')));
              }
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Manage Users', style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      drawer: AppDrawer(
        authRepository: widget.authRepository,
        ticketRepository: widget.ticketRepository,
        profileRepository: widget.profileRepository,
        currentRoute: 'Users',
      ),
      body: ListenableBuilder(
        listenable: _viewModel,
        builder: (context, _) {
          return Column(
            children: [
              _buildFilters(context),
              if (_viewModel.isLoading && _viewModel.users.isEmpty)
                const Expanded(child: Center(child: CircularProgressIndicator()))
              else if (_viewModel.users.isEmpty)
                const Expanded(child: Center(child: Text('No users found.')))
              else
                Expanded(
                  child: ListView.builder(
                    itemCount: _viewModel.users.length,
                    itemBuilder: (context, index) {
                      final user = _viewModel.users[index];
                      return UserCard(
                        userMock: user,
                        onEdit: () => _showUserForm(user),
                        onDelete: () => _confirmDelete(user['id'].toString()),
                      );
                    },
                  ),
                ),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showUserForm(),
        child: const Icon(Icons.person_add),
      ),
    );
  }

  Widget _buildFilters(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        children: [
          Expanded(
            flex: 5,
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Search name or email...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(30), borderSide: BorderSide.none),
                filled: true,
                fillColor: Theme.of(context).colorScheme.surfaceContainerHighest,
                contentPadding: const EdgeInsets.symmetric(vertical: 0),
              ),
              onChanged: _onSearchChanged,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            flex: 4,
            child: DropdownButtonFormField<String>(
              isExpanded: true,
              initialValue: _viewModel.selectedRoleFilter,
              decoration: InputDecoration(
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(30), borderSide: BorderSide.none),
                filled: true,
                fillColor: Theme.of(context).colorScheme.surfaceContainerHighest,
                contentPadding: const EdgeInsets.symmetric(horizontal: 16),
              ),
              items: const [
                DropdownMenuItem(value: 'all', child: Text('All Roles')),
                DropdownMenuItem(value: 'customer', child: Text('Customer')),
                // Foi corrigido aqui de 'support' para 'supporter'
                DropdownMenuItem(value: 'supporter', child: Text('Support')),
              ],
              onChanged: (v) {
                if (v != null) _viewModel.setRoleFilter(v);
              },
            ),
          ),
        ],
      ),
    );
  }
}