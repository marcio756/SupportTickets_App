import '../../../core/network/api_client.dart';
import '../models/ticket.dart';
import '../models/ticket_message.dart';

/// Repository responsible for handling all support ticket operations.
class TicketRepository {
  /// The API client used to perform HTTP requests.
  final ApiClient apiClient;

  /// Initializes the TicketRepository.
  ///
  /// The [apiClient] parameter is required for network communication.
  TicketRepository({required this.apiClient});

  /// Retrieves a list of support tickets.
  ///
  /// Returns a list of [Ticket] objects.
  Future<List<Ticket>> getTickets() async {
    final Map<String, dynamic> response = await apiClient.get('/tickets');
    
    // Extracts the array from the 'data' wrapper typically used in Laravel
    final List<dynamic> dataList = response.containsKey('data') 
        ? response['data'] 
        : response.values.toList();
        
    return dataList.map((json) => Ticket.fromJson(json as Map<String, dynamic>)).toList();
  }

  /// Retrieves details for a specific support ticket.
  ///
  /// [ticketId] The unique identifier of the ticket.
  /// Returns a [Ticket] object.
  Future<Ticket> getTicket(int ticketId) async {
    final Map<String, dynamic> response = await apiClient.get('/tickets/$ticketId');
    final data = response.containsKey('data') ? response['data'] : response;
    
    return Ticket.fromJson(data as Map<String, dynamic>);
  }

  /// Retrieves messages for a specific support ticket.
  ///
  /// [ticketId] The unique identifier of the ticket.
  /// [userId] Optional user identifier for context to define ownership.
  /// Returns a list of [TicketMessage] objects.
  Future<List<TicketMessage>> getTicketMessages(int ticketId, [int? userId]) async {
    final Map<String, dynamic> response = await apiClient.get('/tickets/$ticketId');
    final data = response.containsKey('data') ? response['data'] : response;
    
    final List<dynamic> messages = data['messages'] ?? [];
    return messages.map((m) => TicketMessage.fromJson(m as Map<String, dynamic>, userId ?? 0)).toList();
  }

  /// Creates a new support ticket.
  ///
  /// [title] The title or subject of the ticket.
  /// [description] The detailed issue description.
  /// Returns the newly created [Ticket].
  Future<Ticket> createTicket(String title, String description) async {
    final Map<String, dynamic> response = await apiClient.post('/tickets', data: {
      'title': title,
      'description': description,
    });
    
    final data = response.containsKey('data') ? response['data'] : response;
    return Ticket.fromJson(data as Map<String, dynamic>);
  }

  /// Assigns a ticket to a specific user/agent.
  ///
  /// [ticketId] The unique identifier of the ticket.
  /// [data] A map containing the assignee details.
  /// Returns a [Map] confirming the assignment.
  Future<Map<String, dynamic>> assignTicket(int ticketId, Map<String, dynamic> data) async {
    return await apiClient.post('/tickets/$ticketId/assign', data: data);
  }

  /// Updates the status of a specific ticket.
  ///
  /// [ticketId] The unique identifier of the ticket.
  /// [status] The new status string to apply.
  /// Returns the updated [Ticket].
  Future<Ticket> updateTicketStatus(int ticketId, String status) async {
    final Map<String, dynamic> response = await apiClient.patch(
      '/tickets/$ticketId/status', 
      data: {'status': status}
    );
    
    final data = response.containsKey('data') ? response['data'] : response;
    return Ticket.fromJson(data as Map<String, dynamic>);
  }

  /// Sends a new message within a specific ticket thread.
  ///
  /// [ticketId] The unique identifier of the ticket.
  /// [message] The message content to send.
  /// [userId] Optional user identifier for context to define ownership.
  /// Returns the created [TicketMessage].
  Future<TicketMessage> sendMessage(int ticketId, String message, [int? userId]) async {
    final Map<String, dynamic> response = await apiClient.post(
      '/tickets/$ticketId/messages', 
      data: {'message': message}
    );
    
    final data = response.containsKey('data') ? response['data'] : response;
    return TicketMessage.fromJson(data as Map<String, dynamic>, userId ?? 0);
  }

  /// Ticks or logs time against a specific ticket.
  ///
  /// [ticketId] The unique identifier of the ticket.
  /// [data] A map containing the time logging specifics.
  /// Returns a [Map] confirming the time logged.
  Future<Map<String, dynamic>> tickTime(int ticketId, Map<String, dynamic> data) async {
    return await apiClient.post('/tickets/$ticketId/tick', data: data);
  }
}