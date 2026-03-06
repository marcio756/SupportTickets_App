import '../../../core/network/api_client.dart';

/// Repository responsible for Tag taxonomy management (CRUD).
class TagRepository {
  /// The HTTP client used for network requests.
  final ApiClient apiClient;

  /// Initializes the TagRepository.
  TagRepository({required this.apiClient});

  /// Helper to extract data lists handling both direct arrays and paginated objects.
  List<dynamic> _extractDataList(Map<String, dynamic> response) {
    dynamic payload = response.containsKey('data') ? response['data'] : response;
    if (payload is Map && payload.containsKey('data') && payload['data'] is List) {
      return payload['data'] as List<dynamic>;
    }
    if (payload is List) {
      return payload;
    }
    return [];
  }

  /// Retrieves a list of all available tags.
  Future<List<Map<String, dynamic>>> getTags() async {
    final response = await apiClient.get('/tags');
    return _extractDataList(response).cast<Map<String, dynamic>>();
  }

  /// Creates a new tag in the system.
  Future<Map<String, dynamic>> createTag(Map<String, dynamic> tagData) async {
    final response = await apiClient.post('/tags', data: tagData);
    return response.containsKey('data') ? response['data'] : response;
  }

  /// Updates an existing tag.
  Future<Map<String, dynamic>> updateTag(int tagId, Map<String, dynamic> tagData) async {
    final response = await apiClient.put('/tags/$tagId', data: tagData);
    return response.containsKey('data') ? response['data'] : response;
  }

  /// Permanently deletes a specific tag.
  Future<void> deleteTag(int tagId) async {
    await apiClient.delete('/tags/$tagId');
  }
}