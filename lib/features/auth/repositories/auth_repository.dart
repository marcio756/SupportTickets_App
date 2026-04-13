// Ficheiro: lib/features/auth/repositories/auth_repository.dart
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/network/api_client.dart';

/// Repository responsible for handling authentication and session tokens.
class AuthRepository {
  /// The HTTP client used for network requests.
  final ApiClient apiClient;
  
  /// Local storage for saving and clearing the auth token.
  final SharedPreferences prefs;

  /// Initializes the AuthRepository.
  AuthRepository({required this.apiClient, required this.prefs});

  /// Authenticates a user with the provided credentials.
  /// 
  /// Returns a map containing the token and user data on success, 
  /// or a requirement for 2FA validation.
  Future<Map<String, dynamic>> login(String email, String password) async {
    final response = await apiClient.post('/login', data: {
      'email': email,
      'password': password,
      'device_name': 'mobile_app',
    });
    
    // Automatically save token if present in successful response
    if (response.containsKey('data') && response['data'] is Map) {
      final data = response['data'] as Map<String, dynamic>;
      if (data.containsKey('token')) {
        await prefs.setString(ApiClient.tokenKey, data['token']);
      }
    }
    
    return response;
  }

  /// Validates a Two-Factor Authentication challenge.
  /// 
  /// Requires the user's [email], the verification [code], and the [device_name]
  /// to generate the final access token on the backend.
  Future<Map<String, dynamic>> twoFactorChallenge({
    required String email, 
    required String code, 
    bool isRecoveryCode = false
  }) async {
    final Map<String, dynamic> data = {
      'email': email,
      'device_name': 'mobile_app',
    };

    if (isRecoveryCode) {
      data['recovery_code'] = code;
    } else {
      data['code'] = code;
    }

    final response = await apiClient.post('/two-factor-challenge', data: data);

    if (response.containsKey('data') && response['data'] is Map) {
      final responseData = response['data'] as Map<String, dynamic>;
      if (responseData.containsKey('token')) {
        await prefs.setString(ApiClient.tokenKey, responseData['token']);
      }
    }

    return response;
  }

  /// Requests a password reset link to be sent to the given email.
  Future<Map<String, dynamic>> forgotPassword(String email) async {
    return await apiClient.post('/forgot-password', data: {'email': email});
  }

  /// Resets the user's password using the token received via email.
  Future<Map<String, dynamic>> resetPassword({
    required String email,
    required String token,
    required String password,
    required String passwordConfirmation,
  }) async {
    return await apiClient.post('/reset-password', data: {
      'email': email,
      'token': token,
      'password': password,
      'password_confirmation': passwordConfirmation,
    });
  }

  /// Terminates the current session on the backend and clears local auth.
  Future<void> logout() async {
    try {
      await apiClient.post('/logout');
    } catch (e) {
      // Ignore API errors on logout to ensure local cleanup still happens
    } finally {
      await prefs.remove(ApiClient.tokenKey);
    }
  }

  /// Registers the Firebase Cloud Messaging token with the backend
  /// to enable push notifications for the current device.
  Future<void> registerFcmToken(String token) async {
    await apiClient.post('/fcm-token', data: {'token': token});
  }
}