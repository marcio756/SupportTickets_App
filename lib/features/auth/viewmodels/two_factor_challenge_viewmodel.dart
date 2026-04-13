// Ficheiro: lib/features/auth/viewmodels/two_factor_challenge_viewmodel.dart
import 'package:flutter/foundation.dart';
import '../repositories/auth_repository.dart';

/// ViewModel responsible for handling the 2FA challenge during login.
class TwoFactorChallengeViewModel extends ChangeNotifier {
  final AuthRepository authRepository;

  bool _isLoading = false;
  bool _isSuccess = false;
  String? _errorMessage;

  TwoFactorChallengeViewModel({required this.authRepository});

  bool get isLoading => _isLoading;
  bool get isSuccess => _isSuccess;
  String? get errorMessage => _errorMessage;

  /// Verifies the 2FA code provided by the user.
  /// Requires the [email] from the initial login attempt.
  Future<void> verifyChallenge(String email, String code, {bool isRecoveryCode = false}) async {
    if (code.trim().isEmpty) {
      _errorMessage = 'Por favor, insira o código de verificação.';
      notifyListeners();
      return;
    }

    if (email.trim().isEmpty) {
      _errorMessage = 'Sessão inválida. Volte atrás e inicie sessão novamente.';
      notifyListeners();
      return;
    }

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await authRepository.twoFactorChallenge(
        email: email.trim(),
        code: code.trim(),
        isRecoveryCode: isRecoveryCode,
      );

      if (response.containsKey('data') || response['status'] == 'Success') {
        _isSuccess = true;
      } else {
        _errorMessage = response['message'] ?? 'Código inválido. Tente novamente.';
        _isSuccess = false;
      }
    } catch (e) {
      _errorMessage = 'Erro ao verificar código: ${e.toString().replaceAll('Exception: ', '')}';
      _isSuccess = false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}