// Ficheiro: lib/features/users/ui/user_management_screen.dart
import 'package:flutter/material.dart';
import '../models/user_model.dart';
import '../viewmodels/user_management_viewmodel.dart';
import '../../../core/widgets/custom_text_field.dart';
import '../../../core/widgets/app_drawer.dart';
import '../../auth/repositories/auth_repository.dart';
import '../../tickets/repositories/ticket_repository.dart';
import '../../profile/repositories/profile_repository.dart';

/// Screen responsible for managing system users.
/// Features Server-Side Pagination and Infinite Scrolling.
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
      widget.viewModel.loadUsers(reset: true);
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

  void _confirmRestore(UserModel user) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Restore User'),
        content: Text('Are you sure you want to restore ${user.name}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              await widget.viewModel.restoreUser(user.id); 
            },
            style: TextButton.styleFrom(foregroundColor: Colors.green),
            child: const Text('Restore'),
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
            onPressed: () => widget.viewModel.loadUsers(reset: true),
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
                      const SizedBox(width: 8),
                      Expanded(
                        flex: 1,
                        child: DropdownButtonFormField<String>(
                          isExpanded: true,
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
                      const SizedBox(width: 8),
                      Expanded(
                        flex: 1,
                        child: DropdownButtonFormField<String>(
                          isExpanded: true,
                          key: ValueKey(widget.viewModel.selectedStatusFilter),
                          initialValue: widget.viewModel.selectedStatusFilter,
                          decoration: InputDecoration(
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            contentPadding: const EdgeInsets.symmetric(horizontal: 12),
                          ),
                          hint: const Text('Status'),
                          items: const [
                            DropdownMenuItem(value: 'active', child: Text('Active')),
                            DropdownMenuItem(value: 'trashed', child: Text('Archived')),
                            DropdownMenuItem(value: 'all', child: Text('All')),
                          ],
                          onChanged: widget.viewModel.setStatusFilter,
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
                  child: NotificationListener<ScrollNotification>(
                    onNotification: (ScrollNotification scrollInfo) {
                      // Trigger load more when reaching the bottom of the list
                      if (!widget.viewModel.isLoadingMore && 
                          widget.viewModel.hasMore &&
                          scrollInfo.metrics.pixels >= scrollInfo.metrics.maxScrollExtent - 200) {
                        widget.viewModel.loadMoreUsers();
                        return true;
                      }
                      return false;
                    },
                    child: ListView.builder(
                      itemCount: widget.viewModel.users.length + (widget.viewModel.isLoadingMore ? 1 : 0),
                      itemBuilder: (context, index) {
                        if (index == widget.viewModel.users.length) {
                          return const Padding(
                            padding: EdgeInsets.symmetric(vertical: 16.0),
                            child: Center(child: CircularProgressIndicator()),
                          );
                        }

                        final user = widget.viewModel.users[index];
                        final isDeleted = user.deletedAt != null;

                        return ListTile(
                          leading: CircleAvatar(
                            backgroundColor: isDeleted ? Colors.grey : colorScheme.primaryContainer,
                            child: Text(user.name[0].toUpperCase(), style: TextStyle(color: isDeleted ? Colors.white : colorScheme.onPrimaryContainer)),
                          ),
                          title: Text(
                            user.name, 
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              decoration: isDeleted ? TextDecoration.lineThrough : null,
                              color: isDeleted ? Colors.grey : null,
                            ),
                          ),
                          subtitle: Text('${user.email} • ${user.role}${isDeleted ? ' (Archived)' : ''}'),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              if (!isDeleted) ...[
                                IconButton(
                                  icon: const Icon(Icons.edit, color: Colors.blueGrey),
                                  onPressed: () => _showUserForm(user),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.delete, color: Colors.redAccent),
                                  onPressed: () => _confirmDelete(user),
                                ),
                              ] else ...[
                                IconButton(
                                  icon: const Icon(Icons.restore, color: Colors.green),
                                  tooltip: 'Restore User',
                                  onPressed: () => _confirmRestore(user),
                                ),
                              ]
                            ],
                          ),
                        );
                      },
                    ),
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
                isExpanded: true,
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