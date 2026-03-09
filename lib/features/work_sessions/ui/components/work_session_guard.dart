import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supporttickets_app/features/profile/repositories/profile_repository.dart';
import 'package:supporttickets_app/features/work_sessions/viewmodels/work_session_viewmodel.dart';
import 'package:supporttickets_app/features/work_sessions/ui/components/work_session_timer_widget.dart';

/// A Higher-Order Component (HOC) that guards routes and screens.
/// 
/// If the user is a 'supporter', it verifies if their work session is active.
/// If not, it blocks the child component and displays the WorkSessionTimerWidget.
/// Customers and Admins bypass this guard entirely.
class WorkSessionGuard extends StatefulWidget {
  final ProfileRepository profileRepository;
  final Widget child;

  const WorkSessionGuard({
    super.key,
    required this.profileRepository,
    required this.child,
  });

  @override
  State<WorkSessionGuard> createState() => _WorkSessionGuardState();
}

class _WorkSessionGuardState extends State<WorkSessionGuard> {
  String? _role;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadRole();
  }

  Future<void> _loadRole() async {
    try {
      final profile = await widget.profileRepository.getProfile();
      final data = profile.containsKey('data') ? profile['data'] : profile;
      if (mounted) {
        setState(() {
          _role = data['role'];
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _role = 'customer'; // Default safe fallback
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    /**
     * Customers and Admins don't have work sessions, let them pass
     */
    final currentRole = _role?.toLowerCase() ?? '';
    if (currentRole == 'customer' || currentRole == 'admin') {
      return widget.child;
    }

    // Supporters must be checked
    return Consumer<WorkSessionViewModel>(
      builder: (context, viewModel, _) {
        if (viewModel.isActive) {
          return widget.child;
        }

        // Block UI for non-active sessions
        return Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.lock_clock, size: 80, color: Theme.of(context).colorScheme.error),
                const SizedBox(height: 16),
                Text(
                  'Access Restricted',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),
                Text(
                  'You must start or resume your work session to access this page and perform support actions.',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant
                  ),
                ),
                const SizedBox(height: 32),
                // Provide the timer right here so they don't have to open the drawer
                const WorkSessionTimerWidget(),
              ],
            ),
          ),
        );
      },
    );
  }
}