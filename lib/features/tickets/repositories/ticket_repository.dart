import 'package:dio/dio.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
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

  /// Helper method to safely extract a List from API responses.
  /// It automatically handles both direct Lists and Laravel Paginated objects.
  List<dynamic> _extractDataList(Map<String, dynamic> response) {
    dynamic data = response.containsKey('data') ? response['data'] : response;

    if (data is Map && data.containsKey('data') && data['data'] is List) {
      return data['data'] as List<dynamic>;
    }

    if (data is List) {
      return data;
    }

    if (data is Map) {
      return data.values.toList();
    }

    return [];
  }

  /// Triggers manual synchronization of support emails via IMAP.
  /// Useful for mobile pull-to-refresh actions.
  Future<void> fetchEmails() async {
    await apiClient.post('/emails/fetch');
  }

  /// Retrieves a list of available customers for support agents.
  Future<List<Map<String, dynamic>>> getCustomers() async {
    final Map<String, dynamic> response = await apiClient.get('/customers');
    final List<dynamic> dataList = _extractDataList(response);
        
    return dataList.cast<Map<String, dynamic>>();
  }

  /// Retrieves a list of available tags for support agents.
  Future<List<Map<String, dynamic>>> getTags() async {
    final Map<String, dynamic> response = await apiClient.get('/tags');
    final List<dynamic> dataList = _extractDataList(response);
        
    return dataList.cast<Map<String, dynamic>>();
  }

  /// Retrieves all tickets relevant to the authenticated user, optionally applying filters.
  Future<List<Ticket>> getTickets({Map<String, dynamic>? filters}) async {
    String path = '/tickets';
    
    if (filters != null && filters.isNotEmpty) {
      final queryString = Uri(queryParameters: filters.map((k, v) => MapEntry(k, v.toString()))).query;
      path = '$path?$queryString';
    }

    final Map<String, dynamic> response = await apiClient.get(path);
    final List<dynamic> dataList = _extractDataList(response);
        
    return dataList.map((json) => Ticket.fromJson(json as Map<String, dynamic>)).toList();
  }

  /// Retrieves a specific ticket by its ID.
  Future<Ticket> getTicket(int ticketId) async {
    final Map<String, dynamic> response = await apiClient.get('/tickets/$ticketId');
    final data = response.containsKey('data') ? response['data'] : response;
    
    return Ticket.fromJson(data as Map<String, dynamic>);
  }

  /// Retrieves all messages associated with a specific ticket thread.
  /// Extracts the parent ticket's email to serve as fallback for unmapped external messages.
  Future<List<TicketMessage>> getTicketMessages(int ticketId, [int? userId]) async {
    final Map<String, dynamic> response = await apiClient.get('/tickets/$ticketId');
    final data = response.containsKey('data') ? response['data'] : response;
    
    final String? ticketSenderEmail = data['sender_email'] as String?;
    final List<dynamic> messages = data['messages'] ?? [];
    
    return messages.map((m) => TicketMessage.fromJson(
      m as Map<String, dynamic>, 
      userId ?? 0,
      fallbackEmail: ticketSenderEmail,
    )).toList();
  }

  /// Creates a new support ticket in the system.
  /// Validates between registered customers and external email users.
  Future<Ticket> createTicket(String title, String description, {int? customerId, String? senderEmail}) async {
    final Map<String, dynamic> payload = {
      'title': title,
      'message': description, 
    };

    if (customerId != null) {
      payload['customer_id'] = customerId;
    } else if (senderEmail != null && senderEmail.isNotEmpty) {
      payload['sender_email'] = senderEmail;
    }

    final Map<String, dynamic> response = await apiClient.post('/tickets', data: payload);
    
    final data = response.containsKey('data') ? response['data'] : response;
    return Ticket.fromJson(data as Map<String, dynamic>);
  }

  /// Assigns an existing ticket to the authenticated support agent.
  Future<Map<String, dynamic>> assignTicket(int ticketId, Map<String, dynamic> data) async {
    return await apiClient.post('/tickets/$ticketId/assign', data: data);
  }

  /// Updates the operational status of a specific ticket.
  Future<Ticket> updateTicketStatus(int ticketId, String status) async {
    final Map<String, dynamic> response = await apiClient.patch(
      '/tickets/$ticketId/status', 
      data: {'status': status}
    );
    
    final data = response.containsKey('data') ? response['data'] : response;
    return Ticket.fromJson(data as Map<String, dynamic>);
  }

  /// Synchronizes the tags for a specific ticket.
  Future<Ticket> syncTags(int ticketId, List<int> tagIds) async {
    final Map<String, dynamic> response = await apiClient.put(
      '/tickets/$ticketId/tags',
      data: {'tags': tagIds},
    );

    final data = response.containsKey('data') ? response['data'] : response;
    return Ticket.fromJson(data as Map<String, dynamic>);
  }

  /// Deletes a specific ticket from the system.
  Future<void> deleteTicket(int ticketId) async {
    await apiClient.delete('/tickets/$ticketId');
  }

  /// Sends a new message within a specific ticket thread.
  Future<TicketMessage> sendMessage(int ticketId, String? message, {int? userId, PlatformFile? attachment}) async {
    dynamic payload;
    Options? requestOptions;

    if (attachment != null) {
      MultipartFile multipartFile;

      if (kIsWeb || attachment.bytes != null) {
        multipartFile = MultipartFile.fromBytes(
          attachment.bytes!, 
          filename: attachment.name,
        );
      } else {
        multipartFile = await MultipartFile.fromFile(
          attachment.path!, 
          filename: attachment.name,
        );
      }

      payload = FormData.fromMap({
        'message': message?.trim() ?? '',
        'attachment': multipartFile,
      });
      requestOptions = Options(contentType: 'multipart/form-data');
    } else {
      payload = {'message': message?.trim() ?? ''};
    }

    final Map<String, dynamic> response = await apiClient.post(
      '/tickets/$ticketId/messages', 
      data: payload,
      options: requestOptions,
    );
    
    final ticketData = response.containsKey('data') ? response['data'] : response;
    final String? ticketSenderEmail = ticketData['sender_email'] as String?;
    final List<dynamic> messages = ticketData['messages'] ?? [];
    
    if (messages.isNotEmpty) {
      final lastMessage = messages.last;
      return TicketMessage.fromJson(
        lastMessage as Map<String, dynamic>, 
        userId ?? 0,
        fallbackEmail: ticketSenderEmail,
      );
    }
    
    throw Exception('Message sent but not returned by API.');
  }

  /// Submits a request to deduct or track support time for a specific ticket.
  Future<Map<String, dynamic>> tickTime(int ticketId, Map<String, dynamic> data) async {
    return await apiClient.post('/tickets/$ticketId/tick', data: data);
  }
}