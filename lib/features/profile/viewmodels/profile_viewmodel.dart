// Ficheiro: lib/features/profile/viewmodels/profile_viewmodel.dart
import 'package:flutter/foundation.dart';
import '../repositories/profile_repository.dart';

/// Manages the state and business logic of the user profile, 
/// acting as the single source of truth for the authenticated user's identity and organizational placement.
class ProfileViewModel extends ChangeNotifier {
  final ProfileRepository profileRepository;

  bool _isFetching = true;
  bool _isLoading = false;
  
  String _name = '';
  String _email = '';
  String _teamId = '';
  String _teamName = '';
  bool _hasTwoFactorEnabled = false;

  ProfileViewModel({required this.profileRepository});

  bool get isFetching => _isFetching;
  bool get isLoading => _isLoading;
  String get name => _name;
  String get email => _email;
  String get teamId => _teamId;
  String get teamName => _teamName;
  bool get hasTwoFactorEnabled => _hasTwoFactorEnabled;

  /// Fetches the authenticated user profile data from the backend to hydrate the global application state.
  Future<void> loadProfileData({Function(String)? onError}) async {
    _isFetching = true;
    notifyListeners();

    try {
      final response = await profileRepository.getProfile();
      
      // Safety guard against unexpected response structures from the normalized ApiClient
      final data = (response.containsKey('data')) ? response['data'] : response;

      if (data is Map) {
        _name = data['name'] ?? '';
        _email = data['email'] ?? '';
        
        // Persists the organizational association locally to feed other feature modules (e.g., Teams, Vacations).
        _teamId = data['team_id']?.toString() ?? ''; 
        _teamName = data['team_name']?.toString() ?? ''; 
        
        // Mapeia o estado atual do 2FA a partir do recurso da API
        _hasTwoFactorEnabled = data['has_two_factor_enabled'] ?? false;
      }
    } catch (e) {
      if (onError != null) {
        onError(e.toString().replaceAll('Exception: ', ''));
      }
    } finally {
      _isFetching = false;
      notifyListeners();
    }
  }

  /// Validates and synchronizes the mutated user profile data with the external API.
  Future<void> updateProfile({
    required String name,
    required String email,
    String? newPassword,
    String? confirmPassword,
    required String currentPassword,
    required Function() onSuccess,
    required Function(String) onError,
  }) async {
    _isLoading = true;
    notifyListeners();

    try {
      final Map<String, dynamic> updateData = {
        'name': name.trim(),
        'email': email.trim(),
        'current_password': currentPassword,
      };

      if (newPassword != null && newPassword.isNotEmpty) {
        updateData['password'] = newPassword;
        updateData['password_confirmation'] = confirmPassword;
      }

      await profileRepository.updateProfile(updateData);

      _name = name.trim();
      _email = email.trim();

      onSuccess();
    } catch (e) {
      onError(e.toString().replaceAll('Exception: ', ''));
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Initiates the soft-delete sequence for the current user entity.
  Future<void> deactivateAccount({
    required String password,
    required Function() onSuccess,
    required Function(String) onError,
  }) async {
    try {
      await profileRepository.deleteAccount(data: {'password': password});
      onSuccess();
    } catch (e) {
      onError(e.toString().replaceAll('Exception: ', ''));
    }
  }
}