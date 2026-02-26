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
}