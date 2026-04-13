// Ficheiro: lib/features/auth/viewmodels/login_viewmodel.dart
import 'package:flutter/foundation.dart';
import '../repositories/auth_repository.dart';

/// ViewModel responsible for managing the state and business logic of the authentication process.
class LoginViewModel extends ChangeNotifier {
  final AuthRepository authRepository;

  bool _isLoading = false;
  bool _isSuccess = false;
  bool _requiresTwoFactor = false;
  String? _errorMessage;
  String? _pendingEmail; // <-- Guarda o email para usar no 2FA

  /// Initializes the ViewModel with the required repository.
  LoginViewModel({required this.authRepository});

  bool get isLoading => _isLoading;
  bool get isSuccess => _isSuccess;
  bool get requiresTwoFactor => _requiresTwoFactor;
  String? get errorMessage => _errorMessage;
  String? get pendingEmail => _pendingEmail;

  /// Attempts to authenticate the user.
  /// 
  /// Validates inputs, handles the loading state, and updates success/error/2fa flags.
  Future<void> login(String email, String password) async {
    if (email.trim().isEmpty || password.trim().isEmpty) {
      _errorMessage = 'Por favor, preencha o e-mail e a palavra-passe.';
      notifyListeners();
      return;
    }

    _isLoading = true;
    _errorMessage = null;
    _requiresTwoFactor = false;
    notifyListeners();

    try {
      final response = await authRepository.login(email.trim(), password.trim());
      
      // Check if backend requires 2FA challenge
      if (response['requires_2fa'] == true || response['two_factor'] == true) {
        _requiresTwoFactor = true;
        _isSuccess = false;
        // Memoriza o email devolvido pela API ou o que o utilizador digitou
        _pendingEmail = response['email'] ?? email.trim(); 
      } else if (response.containsKey('data') || response['status'] == 'Success') {
        _isSuccess = true;
      } else {
        _errorMessage = response['message'] ?? 'Credenciais inválidas. Tente novamente.';
        _isSuccess = false;
      }
    } catch (e) {
      _errorMessage = 'Erro ao iniciar sessão: ${e.toString().replaceAll('Exception: ', '')}';
      _isSuccess = false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Resets the state flags to allow re-attempting login after navigating back.
  void resetState() {
    _isSuccess = false;
    _requiresTwoFactor = false;
    _errorMessage = null;
    _pendingEmail = null;
    notifyListeners();
  }
}