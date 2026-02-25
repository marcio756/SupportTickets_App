import 'package:flutter/foundation.dart';
import '../repositories/auth_repository.dart';

/// ViewModel responsible for managing the state and business logic of the authentication process.
class LoginViewModel extends ChangeNotifier {
  final AuthRepository authRepository;

  bool _isLoading = false;
  bool _isSuccess = false;
  String? _errorMessage;

  /// Initializes the ViewModel with the required repository.
  LoginViewModel({required this.authRepository});

  bool get isLoading => _isLoading;
  bool get isSuccess => _isSuccess;
  String? get errorMessage => _errorMessage;

  /// Attempts to authenticate the user.
  /// 
  /// Validates inputs, handles the loading state, and updates success/error flags.
  Future<void> login(String email, String password) async {
    // Basic frontend validation
    if (email.trim().isEmpty || password.trim().isEmpty) {
      _errorMessage = 'Por favor, preencha o e-mail e a palavra-passe.';
      notifyListeners();
      return;
    }

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final success = await authRepository.login(email.trim(), password.trim());
      
      if (success) {
        _isSuccess = true;
      } else {
        _errorMessage = 'Credenciais inválidas. Tente novamente.';
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
}