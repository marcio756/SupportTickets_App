import 'package:flutter/material.dart';
import '../../../core/widgets/app_drawer.dart';
import '../../auth/repositories/auth_repository.dart';
import '../../tickets/repositories/ticket_repository.dart';
import '../repositories/profile_repository.dart';
import '../viewmodels/profile_viewmodel.dart';
import 'components/profile_avatar.dart';
import 'components/profile_form.dart';
import 'components/profile_danger_zone.dart';

/// Main screen responsible for displaying the user profile.
/// Acts as an orchestrator combining the ViewModel and isolated UI components.
class ProfileScreen extends StatefulWidget {
  final AuthRepository authRepository;
  final TicketRepository ticketRepository;
  final ProfileRepository profileRepository;

  const ProfileScreen({
    super.key,
    required this.authRepository,
    required this.ticketRepository,
    required this.profileRepository,
  });

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  late final ProfileViewModel _viewModel;
  final GlobalKey<ProfileFormState> _formComponentKey = GlobalKey<ProfileFormState>();

  @override
  void initState() {
    super.initState();
    _viewModel = ProfileViewModel(profileRepository: widget.profileRepository);
    
    // Load data after first frame to safely show SnackBars if needed
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _viewModel.loadProfileData(
        onError: (message) => _showSnackBar('Failed to load profile: $message', isError: true),
      );
    });
  }

  @override
  void dispose() {
    _viewModel.dispose();
    super.dispose();
  }

  /// Helper to display SnackBars for user feedback.
  void _showSnackBar(String message, {bool isError = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Theme.of(context).colorScheme.error : null,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Profile', style: TextStyle(fontWeight: FontWeight.bold)),
        elevation: 0,
      ),
      drawer: AppDrawer(
        authRepository: widget.authRepository,
        ticketRepository: widget.ticketRepository,
        profileRepository: widget.profileRepository,
        currentRoute: 'Profile',
      ),
      body: ListenableBuilder(
        listenable: _viewModel,
        builder: (context, _) {
          if (_viewModel.isFetching) {
            return const Center(child: CircularProgressIndicator());
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                ProfileAvatar(name: _viewModel.name),
                const SizedBox(height: 32),
                
                ProfileForm(
                  key: _formComponentKey,
                  initialName: _viewModel.name,
                  initialEmail: _viewModel.email,
                  isLoading: _viewModel.isLoading,
                  onSave: (name, email, newPassword, confirmPassword, currentPassword) {
                    _viewModel.updateProfile(
                      name: name,
                      email: email,
                      newPassword: newPassword,
                      confirmPassword: confirmPassword,
                      currentPassword: currentPassword,
                      onSuccess: () {
                        _showSnackBar('Profile updated successfully!');
                        _formComponentKey.currentState?.clearSensitiveFields();
                      },
                      onError: (message) => _showSnackBar('Failed to update: $message', isError: true),
                    );
                  },
                ),
                
                const SizedBox(height: 48),
                
                ProfileDangerZone(
                  onDeactivate: (password) {
                    _viewModel.deactivateAccount(
                      password: password,
                      onSuccess: () => _showSnackBar('Account deactivated.'),
                      onError: (message) => _showSnackBar('Failed to deactivate: $message', isError: true),
                    );
                  },
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}