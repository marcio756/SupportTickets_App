import 'package:flutter/material.dart';
import '../models/user_model.dart';
import '../viewmodels/user_management_viewmodel.dart';
import '../../../core/widgets/custom_text_field.dart';
import '../../../core/widgets/app_drawer.dart';
import '../../auth/repositories/auth_repository.dart';
import '../../tickets/repositories/ticket_repository.dart';
import '../../profile/repositories/profile_repository.dart';

/// Screen responsible for managing system users.
/// Displays a list, filters, and handles create/edit/delete intents.
class UserManagementScreen extends StatefulWidget {
  final UserManagementViewModel viewModel;
  final AuthRepository authRepository;
  final TicketRepository ticketRepository;
  final ProfileRepository profileRepository;

  const UserManagementScreen({
    super.key, 
    required this.viewModel,
    required this.authRepository,
    required this.ticketRepository,
    required this.profileRepository,
  });

  @override
  State<UserManagementScreen> createState() => _UserManagementScreenState();
}

class _UserManagementScreenState extends State<UserManagementScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      widget.viewModel.fetchUsers();
    });
  }

  void _showUserForm([UserModel? user]) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: _UserFormSheet(
          viewModel: widget.viewModel,
          user: user,
        ),
      ),
    );
  }

  void _confirmDelete(UserModel user) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete User'),
        content: Text('Are you sure you want to delete ${user.name}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              await widget.viewModel.deleteUser(user.id); 
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('User Management'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: widget.viewModel.fetchUsers,
          ),
        ],
      ),
      drawer: AppDrawer(
        authRepository: widget.authRepository,
        ticketRepository: widget.ticketRepository,
        profileRepository: widget.profileRepository,
        currentRoute: 'Users',
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showUserForm(),
        child: const Icon(Icons.add),
      ),
      body: ListenableBuilder(
        listenable: widget.viewModel,
        builder: (context, _) {
          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    Expanded(
                      flex: 2,
                      child: TextField(
                        decoration: InputDecoration(
                          hintText: 'Search users...',
                          prefixIcon: const Icon(Icons.search),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                        ),
                        onChanged: widget.viewModel.setSearchQuery,
                      ),
                    ),
                    
                    if (!widget.viewModel.isSupporter) ...[
                      const SizedBox(width: 16),
                      Expanded(
                        flex: 1,
                        child: DropdownButtonFormField<String>(
                          key: ValueKey(widget.viewModel.selectedRoleFilter),
                          initialValue: widget.viewModel.selectedRoleFilter,
                          decoration: InputDecoration(
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            contentPadding: const EdgeInsets.symmetric(horizontal: 12),
                          ),
                          hint: const Text('Role'),
                          items: const [
                            DropdownMenuItem(value: null, child: Text('All')),
                            DropdownMenuItem(value: 'admin', child: Text('Admin')),
                            DropdownMenuItem(value: 'supporter', child: Text('Supporter')),
                            DropdownMenuItem(value: 'customer', child: Text('Customer')),
                          ],
                          onChanged: widget.viewModel.setRoleFilter,
                        ),
                      ),
                    ],
                  ],
                ),
              ),

              if (widget.viewModel.errorMessage != null)
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(
                    widget.viewModel.errorMessage!,
                    style: TextStyle(color: colorScheme.error),
                  ),
                ),
                
              if (widget.viewModel.isLoading && widget.viewModel.users.isEmpty)
                const Expanded(child: Center(child: CircularProgressIndicator())),

              if (!widget.viewModel.isLoading || widget.viewModel.users.isNotEmpty)
                Expanded(
                  child: ListView.builder(
                    itemCount: widget.viewModel.filteredUsers.length,
                    itemBuilder: (context, index) {
                      final user = widget.viewModel.filteredUsers[index];
                      return ListTile(
                        leading: CircleAvatar(
                          backgroundColor: colorScheme.primaryContainer,
                          child: Text(user.name[0].toUpperCase()),
                        ),
                        title: Text(user.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                        subtitle: Text('${user.email} • ${user.role}'),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.edit, color: Colors.blueGrey),
                              onPressed: () => _showUserForm(user),
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete, color: Colors.redAccent),
                              onPressed: () => _confirmDelete(user),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}

class _UserFormSheet extends StatefulWidget {
  final UserManagementViewModel viewModel;
  final UserModel? user;

  const _UserFormSheet({required this.viewModel, this.user});

  @override
  State<_UserFormSheet> createState() => _UserFormSheetState();
}

class _UserFormSheetState extends State<_UserFormSheet> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameCtrl;
  late TextEditingController _emailCtrl;
  late TextEditingController _passwordCtrl;
  String _role = 'customer';

  @override
  void initState() {
    super.initState();
    _nameCtrl = TextEditingController(text: widget.user?.name ?? '');
    _emailCtrl = TextEditingController(text: widget.user?.email ?? '');
    _passwordCtrl = TextEditingController();
    
    // Fallbacks to ensure safe initialization depending on constraints
    if (widget.user != null) {
      _role = widget.user!.role;
    } else if (widget.viewModel.isSupporter) {
      _role = 'customer';
    }
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  void _submit() async {
    if (_formKey.currentState!.validate()) {
      final payload = {
        'name': _nameCtrl.text.trim(),
        'email': _emailCtrl.text.trim(),
        // Final frontend check: Override role entirely if the user is a supporter
        'role': widget.viewModel.isSupporter ? 'customer' : _role,
      };

      if (_passwordCtrl.text.isNotEmpty) {
        payload['password'] = _passwordCtrl.text;
      }

      final success = await widget.viewModel.saveUser(payload, id: widget.user?.id);
      
      if (success && mounted) {
        Navigator.pop(context);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              widget.user == null ? 'Create User' : 'Edit User',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            CustomTextField(
              controller: _nameCtrl,
              hintText: 'Name',
              validator: (v) => v!.isEmpty ? 'Required' : null,
            ),
            const SizedBox(height: 16),
            CustomTextField(
              controller: _emailCtrl,
              hintText: 'Email',
              keyboardType: TextInputType.emailAddress,
              validator: (v) => v!.contains('@') ? null : 'Invalid email',
            ),
            const SizedBox(height: 16),
            
            if (widget.viewModel.isSupporter)
              TextFormField(
                initialValue: 'Customer',
                decoration: const InputDecoration(labelText: 'Role', border: OutlineInputBorder()),
                enabled: false,
              )
            else
              DropdownButtonFormField<String>(
                initialValue: _role,
                decoration: const InputDecoration(hintText: 'Role', border: OutlineInputBorder()),
                items: const [
                  DropdownMenuItem(value: 'admin', child: Text('Admin')),
                  DropdownMenuItem(value: 'supporter', child: Text('Supporter')),
                  DropdownMenuItem(value: 'customer', child: Text('Customer')),
                ],
                onChanged: (v) => setState(() => _role = v!),
              ),
              
            const SizedBox(height: 16),
            CustomTextField(
              controller: _passwordCtrl,
              hintText: widget.user == null ? 'Password' : 'Password (Leave empty to keep)',
              obscureText: true,
              validator: (v) => widget.user == null && v!.isEmpty ? 'Required for new users' : null,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: widget.viewModel.isLoading ? null : _submit,
              child: widget.viewModel.isLoading 
                  ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2))
                  : Text(widget.user == null ? 'Create' : 'Save Changes'),
            ),
          ],
        ),
      ),
    );
  }
}