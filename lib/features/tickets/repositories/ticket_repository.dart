import '../../../core/network/api_client.dart';
import '../models/ticket.dart';
import '../models/ticket_message.dart';

/// Repository responsible for handling all support ticket operations.
class TicketRepository {
  /// The API client used to perform HTTP requests.
  final ApiClient apiClient;

  /// Initializes the TicketRepository.
  TicketRepository({required this.apiClient});

  Future<List<Ticket>> getTickets() async {
    final Map<String, dynamic> response = await apiClient.get('/tickets');
    
    final List<dynamic> dataList = response.containsKey('data') 
        ? response['data'] 
        : response.values.toList();
        
    return dataList.map((json) => Ticket.fromJson(json as Map<String, dynamic>)).toList();
  }

  Future<Ticket> getTicket(int ticketId) async {
    final Map<String, dynamic> response = await apiClient.get('/tickets/$ticketId');
    final data = response.containsKey('data') ? response['data'] : response;
    
    return Ticket.fromJson(data as Map<String, dynamic>);
  }

  Future<List<TicketMessage>> getTicketMessages(int ticketId, [int? userId]) async {
    final Map<String, dynamic> response = await apiClient.get('/tickets/$ticketId');
    final data = response.containsKey('data') ? response['data'] : response;
    
    final List<dynamic> messages = data['messages'] ?? [];
    return messages.map((m) => TicketMessage.fromJson(m as Map<String, dynamic>, userId ?? 0)).toList();
  }

  Future<Ticket> createTicket(String title, String description) async {
    final Map<String, dynamic> response = await apiClient.post('/tickets', data: {
      'title': title,
      // CORREÇÃO: O Laravel Controller exige 'message' nas validações e não 'description'
      'message': description, 
    });
    
    final data = response.containsKey('data') ? response['data'] : response;
    return Ticket.fromJson(data as Map<String, dynamic>);
  }

  Future<Map<String, dynamic>> assignTicket(int ticketId, Map<String, dynamic> data) async {
    return await apiClient.post('/tickets/$ticketId/assign', data: data);
  }

  Future<Ticket> updateTicketStatus(int ticketId, String status) async {
    final Map<String, dynamic> response = await apiClient.patch(
      '/tickets/$ticketId/status', 
      data: {'status': status}
    );
    
    final data = response.containsKey('data') ? response['data'] : response;
    return Ticket.fromJson(data as Map<String, dynamic>);
  }

  Future<TicketMessage> sendMessage(int ticketId, String message, [int? userId]) async {
    final Map<String, dynamic> response = await apiClient.post(
      '/tickets/$ticketId/messages', 
      data: {'message': message}
    );
    
    // O backend devolve a Resource do Ticket inteiro. Extraímos o array de mensagens.
    final ticketData = response.containsKey('data') ? response['data'] : response;
    final List<dynamic> messages = ticketData['messages'] ?? [];
    
    // A nossa nova mensagem é a última da thread devolvida pelo servidor
    if (messages.isNotEmpty) {
      final lastMessage = messages.last;
      return TicketMessage.fromJson(lastMessage as Map<String, dynamic>, userId ?? 0);
    }
    
    throw Exception('Mensagem enviada mas não encontrada na thread do ticket.');
  }

  Future<Map<String, dynamic>> tickTime(int ticketId, Map<String, dynamic> data) async {
    return await apiClient.post('/tickets/$ticketId/tick', data: data);
  }
}