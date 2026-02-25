import '../../../core/network/api_client.dart';

/// Repository responsible for handling user profile data.
class ProfileRepository {
  /// The API client used to perform HTTP requests.
  final ApiClient apiClient;

  /// Initializes the ProfileRepository.
  ///
  /// The [apiClient] parameter is required for network communication.
  ProfileRepository({required this.apiClient});

  /// Retrieves the authenticated user's profile information.
  ///
  /// Returns a [Map] containing the user data.
  Future<Map<String, dynamic>> getProfile() async {
    // ApiClient already returns the decoded JSON Map
    return await apiClient.get('/me');
  }

  /// Updates the authenticated user's profile information.
  ///
  /// [data] A map containing the profile fields to update.
  /// Returns a [Map] containing the updated user data.
  Future<Map<String, dynamic>> updateProfile(Map<String, dynamic> data) async {
    return await apiClient.put('/me', data: data);
  }
}