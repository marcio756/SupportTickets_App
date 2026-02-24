/// Represents a individual message within a ticket's conversation thread.
class TicketMessage {
  final int id;
  final String message;
  final String userName;
  final DateTime createdAt;
  
  /// Helper to identify if the message was sent by the current user locally.
  /// In a real scenario, this would be determined by comparing user IDs.
  final bool isFromMe;

  TicketMessage({
    required this.id,
    required this.message,
    required this.userName,
    required this.createdAt,
    required this.isFromMe,
  });

  /// Maps the API response (TicketMessageResource) to our Dart model.
  factory TicketMessage.fromJson(Map<String, dynamic> json, int currentUserId) {
    return TicketMessage(
      id: json['id'] as int,
      message: json['message'] as String,
      userName: json['user_name'] as String? ?? 'System',
      createdAt: DateTime.parse(json['created_at'] as String),
      // Check if the message sender matches the logged-in user
      isFromMe: json['user_id'] == currentUserId,
    );
  }
}