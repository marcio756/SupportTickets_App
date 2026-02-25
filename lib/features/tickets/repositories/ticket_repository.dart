import 'dart:io';
import 'package:dio/dio.dart';
import '../../../core/network/api_client.dart';
import '../models/ticket.dart';
import '../models/ticket_message.dart';

/// Repository responsible for handling all support ticket operations.
/// Acts as the single source of truth for ticket-related data.
class TicketRepository {
  /// The API client used to perform HTTP requests.
  final ApiClient apiClient;

  /// Initializes the TicketRepository with the required [apiClient].
  TicketRepository({required this.apiClient});

  /// Retrieves a list of available customers for support agents.
  /// * Returns a [List] of [Map] containing customer details.
  Future<List<Map<String, dynamic>>> getCustomers() async {
    final Map<String, dynamic> response = await apiClient.get('/customers');
    
    final List<dynamic> dataList = response.containsKey('data') 
        ? response['data'] 
        : response.values.toList();
        
    return dataList.cast<Map<String, dynamic>>();
  }

  /// Retrieves all tickets relevant to the authenticated user, optionally applying filters.
  /// * [filters] A map of query parameters (e.g., search, status, customers, assignees).
  /// Returns a [List] of [Ticket] objects.
  Future<List<Ticket>> getTickets({Map<String, dynamic>? filters}) async {
    String path = '/tickets';
    
    if (filters != null && filters.isNotEmpty) {
      // Build query string manually assuming ApiClient.get might just append it
      final queryString = Uri(queryParameters: filters.map((k, v) => MapEntry(k, v.toString()))).query;
      path = '$path?$queryString';
    }

    final Map<String, dynamic> response = await apiClient.get(path);
    
    final List<dynamic> dataList = response.containsKey('data') 
        ? response['data'] 
        : response.values.toList();
        
    return dataList.map((json) => Ticket.fromJson(json as Map<String, dynamic>)).toList();
  }

  /// Retrieves a specific ticket by its ID.
  /// * [ticketId] The unique identifier of the ticket.
  /// Returns a [Ticket] object.
  Future<Ticket> getTicket(int ticketId) async {
    final Map<String, dynamic> response = await apiClient.get('/tickets/$ticketId');
    final data = response.containsKey('data') ? response['data'] : response;
    
    return Ticket.fromJson(data as Map<String, dynamic>);
  }

  /// Retrieves all messages associated with a specific ticket thread.
  /// * [ticketId] The unique identifier of the ticket.
  /// [userId] Optional current user ID to determine message ownership (isFromMe).
  /// Returns a [List] of [TicketMessage] objects.
  Future<List<TicketMessage>> getTicketMessages(int ticketId, [int? userId]) async {
    final Map<String, dynamic> response = await apiClient.get('/tickets/$ticketId');
    final data = response.containsKey('data') ? response['data'] : response;
    
    final List<dynamic> messages = data['messages'] ?? [];
    return messages.map((m) => TicketMessage.fromJson(m as Map<String, dynamic>, userId ?? 0)).toList();
  }

  /// Creates a new support ticket in the system.
  /// * [title] The subject of the ticket.
  /// [description] The detailed issue description (sent as 'message').
  /// [customerId] Optional customer ID. Required if the creator is a support agent.
  /// Returns the newly created [Ticket].
  Future<Ticket> createTicket(String title, String description, {int? customerId}) async {
    final Map<String, dynamic> payload = {
      'title': title,
      'message': description, 
    };

    if (customerId != null) {
      payload['customer_id'] = customerId;
    }

    final Map<String, dynamic> response = await apiClient.post('/tickets', data: payload);
    
    final data = response.containsKey('data') ? response['data'] : response;
    return Ticket.fromJson(data as Map<String, dynamic>);
  }

  /// Assigns an existing ticket to the authenticated support agent.
  /// * [ticketId] The unique identifier of the ticket.
  /// [data] Additional data for the assignment process.
  /// Returns a [Map] containing the API response.
  Future<Map<String, dynamic>> assignTicket(int ticketId, Map<String, dynamic> data) async {
    return await apiClient.post('/tickets/$ticketId/assign', data: data);
  }

  /// Updates the operational status of a specific ticket.
  /// * [ticketId] The unique identifier of the ticket.
  /// [status] The new status string (e.g., 'open', 'in_progress', 'resolved').
  /// Returns the updated [Ticket].
  Future<Ticket> updateTicketStatus(int ticketId, String status) async {
    final Map<String, dynamic> response = await apiClient.patch(
      '/tickets/$ticketId/status', 
      data: {'status': status}
    );
    
    final data = response.containsKey('data') ? response['data'] : response;
    return Ticket.fromJson(data as Map<String, dynamic>);
  }

  /// Sends a new message within a specific ticket thread, optionally including a file attachment.
  /// * [ticketId] The unique identifier of the ticket.
  /// [message] The message content.
  /// [userId] Optional current user ID for ownership check.
  /// [attachment] Optional [File] to be uploaded via FormData.
  /// Returns the newly created [TicketMessage].
  Future<TicketMessage> sendMessage(int ticketId, String? message, {int? userId, File? attachment}) async {
    dynamic payload;

    if (attachment != null) {
      final String fileName = attachment.path.split('/').last;
      payload = FormData.fromMap({
        if (message != null && message.trim().isNotEmpty) 'message': message.trim(),
        'attachment': await MultipartFile.fromFile(attachment.path, filename: fileName),
      });
    } else {
      payload = {'message': message};
    }

    final Map<String, dynamic> response = await apiClient.post(
      '/tickets/$ticketId/messages', 
      data: payload
    );
    
    final ticketData = response.containsKey('data') ? response['data'] : response;
    final List<dynamic> messages = ticketData['messages'] ?? [];
    
    if (messages.isNotEmpty) {
      final lastMessage = messages.last;
      return TicketMessage.fromJson(lastMessage as Map<String, dynamic>, userId ?? 0);
    }
    
    throw Exception('Message sent but not found in the ticket thread.');
  }

  /// Submits a request to deduct or track support time for a specific ticket.
  /// * [ticketId] The unique identifier of the ticket.
  /// [data] Payload containing timing information.
  /// Returns a [Map] containing the API response.
  Future<Map<String, dynamic>> tickTime(int ticketId, Map<String, dynamic> data) async {
    return await apiClient.post('/tickets/$ticketId/tick', data: data);
  }
}