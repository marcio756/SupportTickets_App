import '../../../core/network/api_client.dart';

/// Repository responsible for handling user profile data and account settings.
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
    return await apiClient.get('/me');
  }

  /// Updates the authenticated user's profile information.
  ///
  /// [data] A map containing the profile fields to update.
  /// Returns a [Map] containing the updated user data.
  Future<Map<String, dynamic>> updateProfile(Map<String, dynamic> data) async {
    return await apiClient.put('/me', data: data);
  }

  /// Updates the authenticated user's password.
  ///
  /// Requires the current password for verification and the new password data.
  Future<void> updatePassword(Map<String, dynamic> passwordData) async {
    await apiClient.put('/me/password', data: passwordData);
  }

  /// Deletes the authenticated user's account permanently.
  ///
  /// Depending on the backend implementation, it might require sending the current
  /// password in the [data] map for security validation before deletion.
  Future<void> deleteAccount({Map<String, dynamic>? data}) async {
    await apiClient.delete('/me', data: data);
  }
}