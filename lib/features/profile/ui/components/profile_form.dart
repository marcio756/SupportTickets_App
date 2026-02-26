import 'package:flutter/material.dart';

/// Component responsible for the profile update form fields and local validation.
class ProfileForm extends StatefulWidget {
  final String initialName;
  final String initialEmail;
  final bool isLoading;
  final Function(
    String name,
    String email,
    String newPassword,
    String confirmPassword,
    String currentPassword,
  ) onSave;

  const ProfileForm({
    super.key,
    required this.initialName,
    required this.initialEmail,
    required this.isLoading,
    required this.onSave,
  });

  @override
  State<ProfileForm> createState() => ProfileFormState();
}

class ProfileFormState extends State<ProfileForm> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _emailController;
  late final TextEditingController _newPasswordController;
  late final TextEditingController _confirmNewPasswordController;
  late final TextEditingController _currentPasswordController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.initialName);
    _emailController = TextEditingController(text: widget.initialEmail);
    _newPasswordController = TextEditingController();
    _confirmNewPasswordController = TextEditingController();
    _currentPasswordController = TextEditingController();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _newPasswordController.dispose();
    _confirmNewPasswordController.dispose();
    _currentPasswordController.dispose();
    super.dispose();
  }

  /// Triggers the external save callback if the form is valid.
  void _handleSave() {
    if (_formKey.currentState?.validate() ?? false) {
      widget.onSave(
        _nameController.text,
        _emailController.text,
        _newPasswordController.text,
        _confirmNewPasswordController.text,
        _currentPasswordController.text,
      );
    }
  }

  /// Exposes a method to clear sensitive fields after a successful save.
  void clearSensitiveFields() {
    _newPasswordController.clear();
    _confirmNewPasswordController.clear();
    _currentPasswordController.clear();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TextFormField(
            controller: _nameController,
            decoration: InputDecoration(
              labelText: 'Full Name',
              prefixIcon: const Icon(Icons.person_outline),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              filled: true,
              fillColor: colorScheme.surfaceContainerHighest,
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter your name';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _emailController,
            keyboardType: TextInputType.emailAddress,
            decoration: InputDecoration(
              labelText: 'Email Address',
              prefixIcon: const Icon(Icons.email_outlined),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              filled: true,
              fillColor: colorScheme.surfaceContainerHighest,
            ),
            validator: (value) {
              if (value == null || value.isEmpty || !value.contains('@')) {
                return 'Please enter a valid email';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _newPasswordController,
            obscureText: true,
            decoration: InputDecoration(
              labelText: 'New Password (Optional)',
              prefixIcon: const Icon(Icons.lock_outline),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              filled: true,
              fillColor: colorScheme.surfaceContainerHighest,
              helperText: 'Leave blank if you do not want to change it.',
            ),
            validator: (value) {
              if (value != null && value.isNotEmpty && value.length < 8) {
                return 'Password must be at least 8 characters long';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _confirmNewPasswordController,
            obscureText: true,
            decoration: InputDecoration(
              labelText: 'Confirm New Password',
              prefixIcon: const Icon(Icons.lock_reset_outlined),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              filled: true,
              fillColor: colorScheme.surfaceContainerHighest,
            ),
            validator: (value) {
              if (_newPasswordController.text.isNotEmpty && value != _newPasswordController.text) {
                return 'Passwords do not match';
              }
              return null;
            },
          ),
          const SizedBox(height: 24),
          const Divider(),
          const SizedBox(height: 24),
          TextFormField(
            controller: _currentPasswordController,
            obscureText: true,
            decoration: InputDecoration(
              labelText: 'Current Password (Required)',
              prefixIcon: const Icon(Icons.password_rounded),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: colorScheme.primary, width: 2),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: colorScheme.primary.withValues(alpha: 0.5)),
              ),
              filled: true,
              fillColor: colorScheme.surface,
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please provide your current password to save changes';
              }
              return null;
            },
          ),
          const SizedBox(height: 24),
          SizedBox(
            height: 50,
            child: ElevatedButton(
              onPressed: widget.isLoading ? null : _handleSave,
              style: ElevatedButton.styleFrom(
                backgroundColor: colorScheme.primary,
                foregroundColor: colorScheme.onPrimary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: widget.isLoading
                  ? SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(color: colorScheme.onPrimary, strokeWidth: 2),
                    )
                  : const Text('Update Profile', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            ),
          ),
        ],
      ),
    );
  }
}