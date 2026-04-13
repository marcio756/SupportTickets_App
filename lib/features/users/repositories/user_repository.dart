// Ficheiro: lib/features/users/repositories/user_repository.dart
import '../../../core/network/api_client.dart';
import '../models/user_model.dart';

/// Centralized repository for all User CRUD operations against the API.
/// Isolates data-fetching logic from the UI and ViewModels.
class UserRepository {
  final ApiClient apiClient;

  UserRepository({required this.apiClient});

  /// Helper to extract list data regardless of Laravel's pagination wrapping.
  List<dynamic> _extractDataList(Map<String, dynamic> response) {
    dynamic data = response.containsKey('data') ? response['data'] : response;
    if (data is Map && data.containsKey('data') && data['data'] is List) {
      return data['data'] as List<dynamic>;
    }
    return data is List ? data : (data is Map ? data.values.toList() : []);
  }

  /// Fetches a paginated list of users from the system.
  Future<Map<String, dynamic>> getPaginatedUsers({
    int page = 1,
    String query = '',
    String role = '',
  }) async {
    final Map<String, dynamic> queryParams = {'page': page};
    if (query.isNotEmpty) queryParams['search'] = query;
    if (role.isNotEmpty && role != 'All') queryParams['role'] = role.toLowerCase();

    final response = await apiClient.get('/users', queryParameters: queryParams);
    return response;
  }

  /// Old implementation kept for backwards compatibility in non-paginated drop-downs.
  Future<List<UserModel>> getUsers() async {
    final Map<String, dynamic> response = await apiClient.get('/users');
    final List<dynamic> dataList = _extractDataList(response);
        
    return dataList
        .map((json) => UserModel.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  /// Fetches a lightweight list of customers for discovery/dropdowns.
  Future<List<UserModel>> getCustomers() async {
    final Map<String, dynamic> response = await apiClient.get('/customers');
    final List<dynamic> dataList = _extractDataList(response);
        
    return dataList
        .map((json) => UserModel.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  /// Fetches a lightweight list of supporters for discovery/dropdowns.
  Future<List<UserModel>> getSupporters() async {
    final Map<String, dynamic> response = await apiClient.get('/supporters');
    final List<dynamic> dataList = _extractDataList(response);
        
    return dataList
        .map((json) => UserModel.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  /// Sends a payload to create a newly registered user in the system.
  Future<UserModel> createUser(Map<String, dynamic> userData) async {
    final Map<String, dynamic> response = await apiClient.post(
      '/users',
      data: userData,
    );
    
    final data = response.containsKey('data') ? response['data'] : response;
    return UserModel.fromJson(data as Map<String, dynamic>);
  }

  /// Updates an existing user's information.
  Future<UserModel> updateUser(int userId, Map<String, dynamic> userData) async {
    final Map<String, dynamic> response = await apiClient.put(
      '/users/$userId',
      data: userData,
    );
    
    final data = response.containsKey('data') ? response['data'] : response;
    return UserModel.fromJson(data as Map<String, dynamic>);
  }

  /// Soft deletes or permanently deletes a user based on backend logic.
  Future<void> deleteUser(int userId) async {
    await apiClient.delete('/users/$userId');
  }
}