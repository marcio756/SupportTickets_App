import 'package:flutter/material.dart';

class UserFormDialog extends StatefulWidget {
  final Map<String, dynamic>? userMock;
  final String currentUserRole;
  final Function(Map<String, dynamic>) onSave;

  const UserFormDialog({
    super.key, 
    this.userMock, 
    required this.currentUserRole, 
    required this.onSave
  });

  @override
  State<UserFormDialog> createState() => _UserFormDialogState();
}

class _UserFormDialogState extends State<UserFormDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _emailController;
  late final TextEditingController _passwordController;
  String _role = 'customer';

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.userMock?['name'] ?? '');
    _emailController = TextEditingController(text: widget.userMock?['email'] ?? '');
    _passwordController = TextEditingController();
    
    // Impede o Supporter de criar/ver algo além de 'customer'
    if (widget.currentUserRole == 'supporter') {
      _role = 'customer';
    } else {
      final initialRole = widget.userMock?['role']?.toString().toLowerCase();
      _role = (initialRole == 'support' || initialRole == 'supporter') ? 'supporter' : 'customer';
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _submit() {
    if (_formKey.currentState?.validate() ?? false) {
      final data = {
        'name': _nameController.text.trim(),
        'email': _emailController.text.trim(),
        'role': _role,
      };
      if (_passwordController.text.isNotEmpty) {
        data['password'] = _passwordController.text;
      }
      widget.onSave(data);
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.userMock != null;
    return AlertDialog(
      title: Text(isEditing ? 'Edit User' : 'New User'),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Name'),
                validator: (v) => v!.isEmpty ? 'Name is required' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(labelText: 'Email'),
                validator: (v) => v!.isEmpty || !v.contains('@') ? 'Valid email is required' : null,
              ),
              const SizedBox(height: 16),
              
              // Se for o Admin mostra o Dropdown, se for o Supporter bloqueia no Customer
              widget.currentUserRole == 'supporter'
                ? TextFormField(
                    initialValue: 'Customer',
                    decoration: const InputDecoration(labelText: 'Role'),
                    enabled: false,
                    style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant),
                  )
                : DropdownButtonFormField<String>(
                    initialValue: _role,
                    isExpanded: true,
                    decoration: const InputDecoration(labelText: 'Role'),
                    items: const [
                      DropdownMenuItem(value: 'customer', child: Text('Customer')),
                      DropdownMenuItem(value: 'supporter', child: Text('Support')),
                    ],
                    onChanged: (v) => setState(() => _role = v!),
                  ),
                  
              const SizedBox(height: 16),
              TextFormField(
                controller: _passwordController,
                obscureText: true,
                decoration: InputDecoration(
                  labelText: isEditing ? 'New Password (Optional)' : 'Password',
                ),
                validator: (v) {
                  if (!isEditing && (v == null || v.isEmpty)) return 'Password is required';
                  if (v != null && v.isNotEmpty && v.length < 8) return 'Min 8 characters';
                  return null;
                },
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Cancel')),
        ElevatedButton(onPressed: _submit, child: const Text('Save')),
      ],
    );
  }
}