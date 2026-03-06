import '../../../core/network/api_client.dart';

/// Repository responsible for user management operations (CRUD and selections).
class UserRepository {
  /// The API client used to perform HTTP requests.
  final ApiClient apiClient;

  /// Initializes the UserRepository.
  UserRepository({required this.apiClient});

  /// Retrieves a paginated and optionally filtered list of users.
  /// 
  /// [query] A search string to filter users by name or email.
  /// [role] The specific role to filter users. Use 'all' to bypass role filtering.
  /// [page] The pagination page to retrieve.
  Future<Map<String, dynamic>> getUsers({String query = '', String role = 'all', int page = 1}) async {
    final Map<String, dynamic> queryParams = {'page': page.toString()};
    if (query.isNotEmpty) queryParams['query'] = query;
    if (role != 'all') queryParams['role'] = role;

    return await apiClient.get('/users', queryParameters: queryParams);
  }

  /// Creates a new user in the system.
  Future<void> createUser(Map<String, dynamic> userData) async {
    await apiClient.post('/users', data: userData);
  }

  /// Updates an existing user's data.
  Future<void> updateUser(String userId, Map<String, dynamic> userData) async {
    await apiClient.put('/users/$userId', data: userData);
  }

  /// Permanently deletes a user from the system.
  Future<void> deleteUser(String userId) async {
    await apiClient.delete('/users/$userId');
  }

  /// Fetches a lightweight list of users with the 'customer' role.
  /// 
  /// Primarily used for populating dropdowns during ticket creation.
  Future<List<Map<String, dynamic>>> getCustomers() async {
    final response = await apiClient.get('/customers');
    if (response['data'] == null) {
      return [];
    }
    return List<Map<String, dynamic>>.from(response['data']);
  }

  /// Fetches a lightweight list of users with the 'supporter' role.
  /// 
  /// Primarily used for populating dropdowns when manually assigning a ticket.
  Future<List<Map<String, dynamic>>> getSupporters() async {
    final response = await apiClient.get('/supporters');
    if (response['data'] == null) {
      return [];
    }
    return List<Map<String, dynamic>>.from(response['data']);
  }
}