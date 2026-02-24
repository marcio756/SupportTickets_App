import '../../../core/network/api_client.dart';
import '../models/ticket.dart';
import '../models/ticket_message.dart';

/// Repository responsible for handling all support ticket operations.
class TicketRepository {
  final ApiClient _apiClient;

  /// Initializes the TicketRepository.
  ///
  /// [_apiClient] The API client used for network requests.
  TicketRepository(this._apiClient);

  /// Retrieves a list of support tickets.
  ///
  /// Returns a list of [Ticket] objects.
  Future<List<Ticket>> getTickets() async {
    final response = await _apiClient.get('/tickets');
    final List<dynamic> data = response.containsKey('data') ? response['data'] : response;
    return data.map((json) => Ticket.fromJson(json)).toList();
  }

  /// Retrieves details for a specific support ticket.
  ///
  /// [ticketId] The unique identifier of the ticket.
  /// Returns a [Ticket] object.
  Future<Ticket> getTicket(int ticketId) async {
    final response = await _apiClient.get('/tickets/$ticketId');
    final data = response.containsKey('data') ? response['data'] : response;
    return Ticket.fromJson(data);
  }

  /// Retrieves messages for a specific support ticket.
  ///
  /// [ticketId] The unique identifier of the ticket.
  /// [userId] Optional user identifier for context to define ownership.
  /// Returns a list of [TicketMessage] objects.
  Future<List<TicketMessage>> getTicketMessages(int ticketId, [int? userId]) async {
    final response = await _apiClient.get('/tickets/$ticketId');
    final data = response.containsKey('data') ? response['data'] : response;
    final List<dynamic> messages = data['messages'] ?? [];
    return messages.map((m) => TicketMessage.fromJson(m, userId ?? 0)).toList();
  }

  /// Creates a new support ticket.
  ///
  /// [title] The title or subject of the ticket.
  /// [description] The detailed issue description.
  /// Returns the newly created [Ticket].
  Future<Ticket> createTicket(String title, String description) async {
    final response = await _apiClient.post('/tickets', data: {
      'title': title,
      'description': description,
    });
    final data = response.containsKey('data') ? response['data'] : response;
    return Ticket.fromJson(data);
  }

  /// Assigns a ticket to a specific user/agent.
  ///
  /// [ticketId] The unique identifier of the ticket.
  /// [data] A map containing the assignee details.
  /// Returns a Map confirming the assignment.
  Future<Map<String, dynamic>> assignTicket(int ticketId, Map<String, dynamic> data) async {
    return await _apiClient.post('/tickets/$ticketId/assign', data: data);
  }

  /// Updates the status of a specific ticket.
  ///
  /// [ticketId] The unique identifier of the ticket.
  /// [status] The new status string to apply.
  /// Returns the updated [Ticket].
  Future<Ticket> updateTicketStatus(int ticketId, String status) async {
    final response = await _apiClient.patch('/tickets/$ticketId/status', data: {'status': status});
    final data = response.containsKey('data') ? response['data'] : response;
    return Ticket.fromJson(data);
  }

  /// Sends a new message within a specific ticket thread.
  ///
  /// [ticketId] The unique identifier of the ticket.
  /// [message] The message content to send.
  /// [userId] Optional user identifier for context to define ownership.
  /// Returns the created [TicketMessage].
  Future<TicketMessage> sendMessage(int ticketId, String message, [int? userId]) async {
    final response = await _apiClient.post('/tickets/$ticketId/messages', data: {
      'message': message,
    });
    final data = response.containsKey('data') ? response['data'] : response;
    return TicketMessage.fromJson(data, userId ?? 0);
  }

  /// Ticks or logs time against a specific ticket.
  ///
  /// [ticketId] The unique identifier of the ticket.
  /// [data] A map containing the time logging specifics.
  /// Returns a Map confirming the time logged.
  Future<Map<String, dynamic>> tickTime(int ticketId, Map<String, dynamic> data) async {
    return await _apiClient.post('/tickets/$ticketId/tick', data: data);
  }
}