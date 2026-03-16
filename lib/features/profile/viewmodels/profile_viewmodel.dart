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

  ProfileViewModel({required this.profileRepository});

  bool get isFetching => _isFetching;
  bool get isLoading => _isLoading;
  String get name => _name;
  String get email => _email;
  String get teamId => _teamId;
  String get teamName => _teamName;

  /// Fetches the authenticated user profile data from the backend to hydrate the global application state.
  Future<void> loadProfileData({Function(String)? onError}) async {
    _isFetching = true;
    notifyListeners();

    try {
      final response = await profileRepository.getProfile();
      final data = response.containsKey('data') ? response['data'] : response;

      _name = data['name'] ?? '';
      _email = data['email'] ?? '';
      
      // Persists the organizational association locally to feed other feature modules (e.g., Teams, Vacations).
      _teamId = data['team_id']?.toString() ?? ''; 
      _teamName = data['team_name']?.toString() ?? ''; 
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
      // Action pending API integration for deactivation
      // await profileRepository.deactivateAccount(password);
      onSuccess();
    } catch (e) {
      onError(e.toString().replaceAll('Exception: ', ''));
    }
  }
}