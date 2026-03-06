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
  /// Returns a map containing the token and user data on success.
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