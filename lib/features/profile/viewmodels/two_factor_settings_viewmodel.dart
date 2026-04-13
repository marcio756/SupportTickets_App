// Ficheiro: lib/features/profile/viewmodels/two_factor_settings_viewmodel.dart
import 'package:flutter/foundation.dart';
import '../repositories/profile_repository.dart';

/// ViewModel managing the Two-Factor Authentication lifecycle within the profile.
class TwoFactorSettingsViewModel extends ChangeNotifier {
  final ProfileRepository profileRepository;

  bool _isLoading = false;
  bool _isTwoFactorEnabled = false;
  String? _qrCodeSvg;
  String? _setupKey;
  List<String> _recoveryCodes = [];
  String? _errorMessage;

  TwoFactorSettingsViewModel({required this.profileRepository});

  bool get isLoading => _isLoading;
  bool get isTwoFactorEnabled => _isTwoFactorEnabled;
  String? get qrCodeSvg => _qrCodeSvg;
  String? get setupKey => _setupKey;
  List<String> get recoveryCodes => _recoveryCodes;
  String? get errorMessage => _errorMessage;

  /// Sets the initial 2FA status from the parent profile load.
  void setInitialStatus(bool isEnabled) {
    _isTwoFactorEnabled = isEnabled;
    notifyListeners();
  }

  /// Initiates the 2FA enablement process, retrieving the setup secrets.
  Future<void> enable2FA() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await profileRepository.enableTwoFactor();
      
      if (response['svg'] != null) {
        _qrCodeSvg = response['svg'];
      }
      if (response['secretKey'] != null) {
        _setupKey = response['secretKey'];
      }
      
    } catch (e) {
      _errorMessage = 'Falha ao iniciar 2FA: ${e.toString().replaceAll('Exception: ', '')}';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Confirms enablement by sending the generated OTP.
  Future<bool> confirm2FA(String code) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await profileRepository.confirmTwoFactor(code);
      _isTwoFactorEnabled = true;
      _qrCodeSvg = null; // Clear secrets from memory after confirmation
      _setupKey = null;
      await fetchRecoveryCodes();
      return true;
    } catch (e) {
      _errorMessage = 'Código incorreto. Falha ao confirmar 2FA.';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Disables 2FA for the account.
  Future<void> disable2FA() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await profileRepository.disableTwoFactor();
      _isTwoFactorEnabled = false;
      _recoveryCodes = [];
    } catch (e) {
      _errorMessage = 'Falha ao desativar 2FA.';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Fetches the current recovery codes.
  Future<void> fetchRecoveryCodes() async {
    _isLoading = true;
    notifyListeners();

    try {
      final response = await profileRepository.getRecoveryCodes();
      if (response.containsKey('data') && response['data'] is List) {
        _recoveryCodes = List<String>.from(response['data']);
      }
    } catch (e) {
      _errorMessage = 'Não foi possível obter códigos de recuperação.';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Regenerates all recovery codes.
  Future<void> regenerateRecoveryCodes() async {
    _isLoading = true;
    notifyListeners();

    try {
      await profileRepository.regenerateRecoveryCodes();
      await fetchRecoveryCodes(); // Refresh the list
    } catch (e) {
      _errorMessage = 'Falha ao regenerar códigos.';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}