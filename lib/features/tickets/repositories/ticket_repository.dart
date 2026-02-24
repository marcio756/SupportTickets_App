import '../../../core/network/api_client.dart';
import '../models/ticket.dart';

/// Repository responsible for handling all network operations related to tickets.
/// It abstracts the data fetching and serialization away from the UI layer.
class TicketRepository {
  final ApiClient _apiClient;

  /// Initializes the repository with the required HTTP client dependency.
  ///
  /// [_apiClient] The core network client used to make requests to the API.
  TicketRepository(this._apiClient);

  /// Fetches a list of tickets for the currently authenticated user.
  ///
  /// Returns a Future containing a List of [Ticket] objects.
  /// Throws an Exception if the network request fails.
  Future<List<Ticket>> getTickets() async {
    // Assuming your Laravel API returns a paginated list or data array 
    // at the '/tickets' endpoint.
    final response = await _apiClient.get('/tickets');

    // Extract the list from the 'data' wrapper typical in Laravel APIs
    final List<dynamic> rawData = response['data'] ?? [];

    // Map the raw JSON representations into heavily typed Ticket objects
    return rawData
        .map((json) => Ticket.fromJson(json as Map<String, dynamic>))
        .toList();
  }
}