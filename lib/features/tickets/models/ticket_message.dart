/// Represents a individual message within a ticket's conversation thread.
class TicketMessage {
  final int id;
  final String message;
  final String userName;
  final DateTime createdAt;
  final bool isFromMe;
  final String? attachmentUrl;

  /// Initializes a new TicketMessage instance.
  TicketMessage({
    required this.id,
    required this.message,
    required this.userName,
    required this.createdAt,
    required this.isFromMe,
    this.attachmentUrl,
  });

  /// Maps the API response to our Dart model with multi-key support.
  /// 
  /// [json] The map containing the API data.
  /// [currentUserId] Used to determine if the message belongs to the current user.
  /// Returns a configured [TicketMessage] instance.
  factory TicketMessage.fromJson(Map<String, dynamic> json, int currentUserId) {
    // Looks for user data in flexible keys depending on API variations
    final userData = (json['sender'] ?? json['user'] ?? json['customer']) as Map<String, dynamic>?;

    return TicketMessage(
      id: json['id'] as int,
      // Provide a fallback empty string for messages that only contain attachments
      message: json['message'] as String? ?? '',
      userName: userData?['name'] as String? ?? 'System',
      createdAt: DateTime.parse(json['created_at'] as String),
      isFromMe: userData != null && userData['id'] == currentUserId,
      attachmentUrl: json['attachment_url'] as String?,
    );
  }
}