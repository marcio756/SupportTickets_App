import '../../../core/network/api_client.dart';
import '../models/tag.dart';

/// Repository responsible for CRUD operations on Tags.
class TagRepository {
  final ApiClient apiClient;

  TagRepository({required this.apiClient});

  /// Helper method to safely extract a List from paginated API responses.
  List<dynamic> _extractDataList(Map<String, dynamic> response) {
    dynamic data = response.containsKey('data') ? response['data'] : response;
    if (data is Map && data.containsKey('data') && data['data'] is List) {
      return data['data'] as List<dynamic>;
    }
    if (data is List) return data;
    if (data is Map) return data.values.toList();
    return [];
  }

  /// Fetches all available tags from the server.
  Future<List<Tag>> getTags() async {
    final response = await apiClient.get('/tags');
    final dataList = _extractDataList(response);
    return dataList.map((json) => Tag.fromJson(json as Map<String, dynamic>)).toList();
  }

  /// Creates a new tag.
  Future<Tag> createTag(String name, String? color) async {
    final Map<String, dynamic> payload = {'name': name};
    if (color != null && color.trim().isNotEmpty) payload['color'] = color;

    final response = await apiClient.post('/tags', data: payload);
    final data = response.containsKey('data') ? response['data'] : response;
    return Tag.fromJson(data as Map<String, dynamic>);
  }

  /// Updates an existing tag.
  Future<Tag> updateTag(int id, String name, String? color) async {
    final Map<String, dynamic> payload = {'name': name};
    if (color != null && color.trim().isNotEmpty) payload['color'] = color;

    final response = await apiClient.put('/tags/$id', data: payload);
    final data = response.containsKey('data') ? response['data'] : response;
    return Tag.fromJson(data as Map<String, dynamic>);
  }

  /// Deletes a tag by its ID.
  Future<void> deleteTag(int id) async {
    await apiClient.delete('/tags/$id');
  }
}