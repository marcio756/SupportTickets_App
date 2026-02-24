import '../../../core/network/api_client.dart';

/// Repository responsible for handling user profile data.
class ProfileRepository {
  final ApiClient _apiClient;

  /// Initializes the ProfileRepository.
  ///
  /// [_apiClient] The API client used for network requests.
  ProfileRepository(this._apiClient);

  /// Retrieves the authenticated user's profile information.
  ///
  /// Returns a Map containing the user data.
  Future<Map<String, dynamic>> getProfile() async {
    return await _apiClient.get('/me');
  }

  /// Updates the authenticated user's profile information.
  ///
  /// [data] A map containing the profile fields to update.
  /// Returns a Map containing the updated user data.
  Future<Map<String, dynamic>> updateProfile(Map<String, dynamic> data) async {
    return await _apiClient.put('/me', data: data);
  }
}