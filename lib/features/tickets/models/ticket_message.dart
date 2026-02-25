
/// Represents a individual message within a ticket's conversation thread.
class TicketMessage {
  final int id;
  final String message;
  final String userName;
  final DateTime createdAt;
  final bool isFromMe;

  TicketMessage({
    required this.id,
    required this.message,
    required this.userName,
    required this.createdAt,
    required this.isFromMe,
  });

  /// Maps the API response to our Dart model with multi-key support.
  factory TicketMessage.fromJson(Map<String, dynamic> json, int currentUserId) {
    // Procura o utilizador em 'sender', 'user' ou 'customer' de forma flexível
    final userData = (json['sender'] ?? json['user'] ?? json['customer']) as Map<String, dynamic>?;

    return TicketMessage(
      id: json['id'] as int,
      message: json['message'] as String,
      // Se encontrar o objeto, usa o nome; caso contrário, 'System'
      userName: userData?['name'] as String? ?? 'System',
      createdAt: DateTime.parse(json['created_at'] as String),
      // Verifica a propriedade 'id' dentro do objeto de utilizador encontrado
      isFromMe: userData != null && userData['id'] == currentUserId,
    );
  }
}