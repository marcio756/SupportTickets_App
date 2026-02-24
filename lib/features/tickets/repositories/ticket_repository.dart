import '../../../core/network/api_client.dart';
import '../models/ticket.dart';
import '../models/ticket_message.dart';

/// Repository responsible for handling all network operations related to tickets.
/// It abstracts the data fetching and serialization away from the UI layer.
class TicketRepository {
  final ApiClient _apiClient;

  TicketRepository(this._apiClient);

  /// Fetches a list of tickets for the currently authenticated user.
  Future<List<Ticket>> getTickets() async {
    final response = await _apiClient.get('/tickets');
    final List<dynamic> rawData = response['data'] ?? [];
    return rawData.map((json) => Ticket.fromJson(json as Map<String, dynamic>)).toList();
  }

  /// Fetches the complete message history for a specific ticket.
  Future<List<TicketMessage>> getTicketMessages(int ticketId, int currentUserId) async {
    final response = await _apiClient.get('/tickets/$ticketId/messages');
    final List<dynamic> rawData = response['data'] ?? [];
    return rawData.map((json) => TicketMessage.fromJson(json as Map<String, dynamic>, currentUserId)).toList();
  }

  /// Sends a new message/reply to an existing ticket.
  Future<TicketMessage> sendMessage(int ticketId, String message, int currentUserId) async {
    final response = await _apiClient.post(
      '/tickets/$ticketId/messages',
      data: {'message': message},
    );
    return TicketMessage.fromJson(response['data'] as Map<String, dynamic>, currentUserId);
  }

  /// Creates a new support ticket in the backend.
  /// 
  /// [title] The summary of the issue.
  /// [description] The detailed explanation.
  /// Returns the newly created [Ticket] object.
  Future<Ticket> createTicket(String title, String description) async {
    final response = await _apiClient.post(
      '/tickets',
      data: {
        'title': title,
        'description': description,
      },
    );
    return Ticket.fromJson(response['data'] as Map<String, dynamic>);
  }
}