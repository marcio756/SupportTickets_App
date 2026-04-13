// Ficheiro: lib/features/auth/ui/two_factor_challenge_screen.dart
import 'package:flutter/material.dart';
import '../repositories/auth_repository.dart';
import '../viewmodels/two_factor_challenge_viewmodel.dart';
import '../../dashboard/ui/dashboard_screen.dart';
import '../../tickets/repositories/ticket_repository.dart';
import '../../profile/repositories/profile_repository.dart';

/// Screen for inputting the Two-Factor Authentication code.
class TwoFactorChallengeScreen extends StatefulWidget {
  final AuthRepository authRepository;
  final TicketRepository ticketRepository;
  final ProfileRepository profileRepository;
  
  // Propriedade obrigatória para receber o email do ecrã de Login
  final String pendingEmail;

  const TwoFactorChallengeScreen({
    super.key,
    required this.authRepository,
    required this.ticketRepository,
    required this.profileRepository,
    required this.pendingEmail,
  });

  @override
  State<TwoFactorChallengeScreen> createState() => _TwoFactorChallengeScreenState();
}

class _TwoFactorChallengeScreenState extends State<TwoFactorChallengeScreen> {
  late final TwoFactorChallengeViewModel _viewModel;
  final _codeController = TextEditingController();
  bool _useRecoveryCode = false;

  @override
  void initState() {
    super.initState();
    _viewModel = TwoFactorChallengeViewModel(authRepository: widget.authRepository);
    _viewModel.addListener(_onViewModelChange);
  }

  @override
  void dispose() {
    _viewModel.removeListener(_onViewModelChange);
    _viewModel.dispose();
    _codeController.dispose();
    super.dispose();
  }

  void _onViewModelChange() {
    if (_viewModel.isSuccess) {
      if (mounted) {
        // Limpa a pilha de navegação e vai para o Dashboard após validar o 2FA
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(
            builder: (_) => DashboardScreen(
              authRepository: widget.authRepository,
              ticketRepository: widget.ticketRepository,
              profileRepository: widget.profileRepository,
            ),
          ),
          (route) => false,
        );
      }
    } else if (_viewModel.errorMessage != null && !_viewModel.isLoading) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(_viewModel.errorMessage!),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    }
  }

  void _submitCode() {
    FocusScope.of(context).unfocus();
    // Envia o email pendente e o código para o ViewModel
    _viewModel.verifyChallenge(
      widget.pendingEmail, 
      _codeController.text, 
      isRecoveryCode: _useRecoveryCode
    );
  }

  void _toggleRecoveryMode() {
    setState(() {
      _useRecoveryCode = !_useRecoveryCode;
      _codeController.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Verificação em 2 Passos'),
        elevation: 0,
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: ListenableBuilder(
            listenable: _viewModel,
            builder: (context, _) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Icon(
                    Icons.security_rounded,
                    size: 80,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  const SizedBox(height: 24),
                  Text(
                    _useRecoveryCode 
                        ? 'Usar Código de Recuperação' 
                        : 'Confirme o seu acesso',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    _useRecoveryCode 
                        ? 'Insira um dos seus códigos de recuperação de emergência.'
                        : 'Abra a sua aplicação de autenticação e insira o código para ${widget.pendingEmail}.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 16,
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 32),
                  TextField(
                    controller: _codeController,
                    enabled: !_viewModel.isLoading,
                    keyboardType: _useRecoveryCode ? TextInputType.text : TextInputType.number,
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 24, letterSpacing: 4.0),
                    decoration: InputDecoration(
                      labelText: _useRecoveryCode ? 'Código de Recuperação' : 'Código de 6 dígitos',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      filled: true,
                      fillColor: Theme.of(context).colorScheme.surfaceContainerHighest,
                    ),
                    onSubmitted: (_) => _submitCode(),
                  ),
                  const SizedBox(height: 32),
                  SizedBox(
                    height: 55,
                    child: ElevatedButton(
                      onPressed: _viewModel.isLoading ? null : _submitCode,
                      style: ElevatedButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: _viewModel.isLoading
                          ? const SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Text(
                              'Verificar',
                              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                            ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextButton(
                    onPressed: _viewModel.isLoading ? null : _toggleRecoveryMode,
                    child: Text(
                      _useRecoveryCode 
                          ? 'Usar aplicação de autenticação' 
                          : 'Não tem acesso ao dispositivo? Usar código de recuperação.',
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}