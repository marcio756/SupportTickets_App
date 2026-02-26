import 'package:flutter/material.dart';
import '../../../core/widgets/app_drawer.dart';
import '../../auth/repositories/auth_repository.dart';
import '../../tickets/repositories/ticket_repository.dart';
import '../../profile/repositories/profile_repository.dart';
import 'components/user_card.dart';

/// Screen for support agents to manage system users.
/// Contains searching, filtering by role, and listing users.
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
  String _searchQuery = '';
  String _selectedRoleFilter = 'all';

  // Mock data representing the users fetched from API
  final List<Map<String, dynamic>> _mockUsers = [
    {'id': '1', 'name': 'Alice Smith', 'email': 'alice@example.com', 'role': 'customer'},
    {'id': '2', 'name': 'Bob Support', 'email': 'bob@support.com', 'role': 'support'},
    {'id': '3', 'name': 'Charlie Brown', 'email': 'charlie@example.com', 'role': 'customer'},
  ];

  /// Filters the mock data based on search input and role dropdown.
  List<Map<String, dynamic>> get _filteredUsers {
    return _mockUsers.where((user) {
      final matchesSearch = user['name'].toString().toLowerCase().contains(_searchQuery.toLowerCase()) ||
                            user['email'].toString().toLowerCase().contains(_searchQuery.toLowerCase());
      final matchesRole = _selectedRoleFilter == 'all' || user['role'] == _selectedRoleFilter;
      return matchesSearch && matchesRole;
    }).toList();
  }

  void _handleEditUser(String userId) {
    // Action pending API integration: Open edit bottom sheet or screen
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Edit user $userId tapped')));
  }

  void _handleDeleteUser(String userId) {
    // Action pending API integration: Show confirmation dialog and call API to delete
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Delete user $userId tapped')));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Manage Users', style: TextStyle(fontWeight: FontWeight.bold)),
        elevation: 0,
      ),
      drawer: AppDrawer(
        authRepository: widget.authRepository,
        ticketRepository: widget.ticketRepository,
        profileRepository: widget.profileRepository,
        currentRoute: 'Users',
      ),
      body: Column(
        children: [
          _buildFilters(context),
          Expanded(
            child: ListView.builder(
              itemCount: _filteredUsers.length,
              itemBuilder: (context, index) {
                final user = _filteredUsers[index];
                return UserCard(
                  userMock: user,
                  onEdit: () => _handleEditUser(user['id']),
                  onDelete: () => _handleDeleteUser(user['id']),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Action pending API integration: Open create user flow
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Create user tapped')));
        },
        child: const Icon(Icons.person_add),
      ),
    );
  }

  /// Builds the search bar and role filter dropdown.
  Widget _buildFilters(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Search name or email...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: Theme.of(context).colorScheme.surfaceContainerHighest,
                contentPadding: const EdgeInsets.symmetric(vertical: 0),
              ),
              onChanged: (value) => setState(() => _searchQuery = value),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            flex: 1,
            child: DropdownButtonFormField<String>(
              initialValue: _selectedRoleFilter,
              decoration: InputDecoration(
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: Theme.of(context).colorScheme.surfaceContainerHighest,
                contentPadding: const EdgeInsets.symmetric(horizontal: 16),
              ),
              items: const [
                DropdownMenuItem(value: 'all', child: Text('All Roles')),
                DropdownMenuItem(value: 'customer', child: Text('Customer')),
                DropdownMenuItem(value: 'support', child: Text('Support')),
              ],
              onChanged: (value) {
                if (value != null) setState(() => _selectedRoleFilter = value);
              },
            ),
          ),
        ],
      ),
    );
  }
}