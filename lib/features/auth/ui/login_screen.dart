import 'package:flutter/material.dart';
import '../repositories/auth_repository.dart';
import '../viewmodels/login_viewmodel.dart';
import '../../dashboard/ui/dashboard_screen.dart';
import '../../tickets/repositories/ticket_repository.dart';
import '../../profile/repositories/profile_repository.dart';

/// Screen responsible for displaying the authentication form.
class LoginScreen extends StatefulWidget {
  final AuthRepository authRepository;
  final TicketRepository ticketRepository;
  final ProfileRepository profileRepository;

  const LoginScreen({
    super.key,
    required this.authRepository,
    required this.ticketRepository,
    required this.profileRepository,
  });

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  late final LoginViewModel _viewModel;
  
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _viewModel = LoginViewModel(authRepository: widget.authRepository);
    _viewModel.addListener(_onViewModelChange);
  }

  @override
  void dispose() {
    _viewModel.removeListener(_onViewModelChange);
    _viewModel.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  /// Listens to ViewModel state changes to handle navigation or error reporting.
  void _onViewModelChange() {
    if (_viewModel.isSuccess) {
      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (_) => DashboardScreen(
              authRepository: widget.authRepository,
              ticketRepository: widget.ticketRepository,
              profileRepository: widget.profileRepository,
            ),
          ),
        );
      }
    } else if (_viewModel.errorMessage != null && !_viewModel.isLoading) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(_viewModel.errorMessage!), 
            backgroundColor: Colors.redAccent
          ),
        );
      }
    }
  }

  /// Initiates the login process by validating and sending credentials.
  void _submitLogin() {
    FocusScope.of(context).unfocus();
    _viewModel.login(_emailController.text, _passwordController.text);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 48.0),
          child: ListenableBuilder(
            listenable: _viewModel,
            builder: (context, _) {
              return Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Icon(
                    Icons.support_agent_rounded, 
                    size: 100, 
                    color: Theme.of(context).colorScheme.primary
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'Support Tickets',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 28, 
                      fontWeight: FontWeight.bold, 
                      color: Theme.of(context).colorScheme.onSurface
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Sign in to your account',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 16, 
                      color: Theme.of(context).colorScheme.onSurfaceVariant
                    ),
                  ),
                  const SizedBox(height: 48),

                  TextField(
                    controller: _emailController,
                    enabled: !_viewModel.isLoading,
                    keyboardType: TextInputType.emailAddress,
                    textInputAction: TextInputAction.next,
                    decoration: InputDecoration(
                      labelText: 'Email Address',
                      prefixIcon: const Icon(Icons.email_outlined),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      filled: true,
                      fillColor: Theme.of(context).colorScheme.surfaceContainerHighest,
                    ),
                  ),
                  const SizedBox(height: 16),

                  TextField(
                    controller: _passwordController,
                    enabled: !_viewModel.isLoading,
                    obscureText: true,
                    textInputAction: TextInputAction.done,
                    onSubmitted: (_) => _submitLogin(),
                    decoration: InputDecoration(
                      labelText: 'Password',
                      prefixIcon: const Icon(Icons.lock_outline),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      filled: true,
                      fillColor: Theme.of(context).colorScheme.surfaceContainerHighest,
                    ),
                  ),
                  const SizedBox(height: 32),

                  SizedBox(
                    height: 55,
                    child: ElevatedButton(
                      onPressed: _viewModel.isLoading ? null : _submitLogin,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Theme.of(context).colorScheme.primary,
                        foregroundColor: Theme.of(context).colorScheme.onPrimary,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 2,
                      ),
                      child: _viewModel.isLoading
                          ? SizedBox(
                              width: 24, 
                              height: 24, 
                              child: CircularProgressIndicator(
                                color: Theme.of(context).colorScheme.onPrimary, 
                                strokeWidth: 2
                              )
                            )
                          : const Text(
                              'Login', 
                              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)
                            ),
                    ),
                  ),
                ],
              );
            }
          ),
        ),
      ),
    );
  }
}