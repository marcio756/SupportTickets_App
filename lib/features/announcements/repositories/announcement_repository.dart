// Ficheiro: lib/features/announcements/repositories/announcement_repository.dart
import '../../../core/network/api_client.dart';
import '../models/announcement.dart';

/// Handles data fetching for Announcements from the backend.
class AnnouncementRepository {
  final ApiClient apiClient;

  AnnouncementRepository({required this.apiClient});

  /// Fetches paginated announcements.
  Future<Map<String, dynamic>> getAnnouncements({int page = 1}) async {
    return await apiClient.get('/announcements', queryParameters: {'page': page});
  }

  /// Creates a new announcement and dispatches emails.
  Future<Announcement> createAnnouncement(Map<String, dynamic> payload) async {
    final response = await apiClient.post('/announcements', data: payload);
    final data = response.containsKey('data') ? response['data'] : response;
    return Announcement.fromJson(data as Map<String, dynamic>);
  }

  /// Fetches paginated users with the 'customer' role.
  /// Supports searching by name or email.
  Future<Map<String, dynamic>> getCustomers({int page = 1, String search = ''}) async {
    try {
      final queryParams = <String, dynamic>{
        'role': 'customer',
        'per_page': 10,
        'page': page,
      };
      
      if (search.isNotEmpty) {
        queryParams['search'] = search;
      }
      
      final response = await apiClient.get('/users', queryParameters: queryParams);
      return response;
    } catch (e) {
      return {};
    }
  }
}