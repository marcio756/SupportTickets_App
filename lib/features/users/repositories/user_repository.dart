import '../../../core/network/api_client.dart';

class UserRepository {
  final ApiClient apiClient;

  UserRepository({required this.apiClient});

  Future<Map<String, dynamic>> getUsers({String query = '', String role = 'all', int page = 1}) async {
    final Map<String, dynamic> queryParams = {'page': page.toString()};
    if (query.isNotEmpty) queryParams['query'] = query;
    if (role != 'all') queryParams['role'] = role;

    return await apiClient.get('/users', queryParameters: queryParams);
  }

  Future<void> createUser(Map<String, dynamic> userData) async {
    await apiClient.post('/users', data: userData);
  }

  Future<void> updateUser(String userId, Map<String, dynamic> userData) async {
    await apiClient.put('/users/$userId', data: userData);
  }

  Future<void> deleteUser(String userId) async {
    await apiClient.delete('/users/$userId');
  }

  /// Fetches a lightweight list of users with the 'customer' role.
  /// 
  /// Useful for populating dropdowns during ticket creation.
  Future<List<Map<String, dynamic>>> getCustomers() async {
    final response = await apiClient.get('/customers');
    if (response['data'] == null) {
      return [];
    }
    return List<Map<String, dynamic>>.from(response['data']);
  }

  /// Fetches a lightweight list of users with the 'supporter' role.
  /// 
  /// Useful for populating dropdowns when assigning a ticket.
  Future<List<Map<String, dynamic>>> getSupporters() async {
    final response = await apiClient.get('/supporters');
    if (response['data'] == null) {
      return [];
    }
    return List<Map<String, dynamic>>.from(response['data']);
  }
}