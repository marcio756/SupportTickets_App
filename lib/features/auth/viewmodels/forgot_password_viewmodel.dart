import 'package:flutter/foundation.dart';
import '../repositories/auth_repository.dart';

/// ViewModel managing the request of a password reset link.
class ForgotPasswordViewModel extends ChangeNotifier {
  final AuthRepository authRepository;

  bool _isLoading = false;
  bool _isSuccess = false;
  String? _errorMessage;

  ForgotPasswordViewModel({required this.authRepository});

  bool get isLoading => _isLoading;
  bool get isSuccess => _isSuccess;
  String? get errorMessage => _errorMessage;

  /// Requests a password reset link for the provided email.
  Future<void> requestPasswordReset(String email) async {
    if (email.trim().isEmpty || !email.contains('@')) {
      _errorMessage = 'Por favor, insira um e-mail válido.';
      notifyListeners();
      return;
    }

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await authRepository.forgotPassword(email.trim());
      _isSuccess = true;
    } catch (e) {
      _errorMessage = 'Erro ao pedir recuperação: ${e.toString().replaceAll('Exception: ', '')}';
      _isSuccess = false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}