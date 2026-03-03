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
  /// [fallbackEmail] An optional email address inherited from the parent ticket.
  /// Returns a configured [TicketMessage] instance.
  factory TicketMessage.fromJson(Map<String, dynamic> json, int currentUserId, {String? fallbackEmail}) {
    // Looks for user data in flexible keys depending on API variations
    final userData = (json['sender'] ?? json['user'] ?? json['customer']) as Map<String, dynamic>?;

    String name = 'System';
    
    if (userData != null && userData['name'] != null) {
      name = userData['name'] as String;
    } else {
      // Try to get email directly from the message, or fallback to the ticket's email
      final String? rawEmail = (json['sender_email'] as String?) ?? fallbackEmail;
      
      if (rawEmail != null && rawEmail.isNotEmpty) {
        // Split the email at the '@' and take the first part to keep UI clean
        name = rawEmail.contains('@') ? rawEmail.split('@').first : rawEmail;
      }
    }

    return TicketMessage(
      id: json['id'] as int,
      // Provide a fallback empty string for messages that only contain attachments
      message: json['message'] as String? ?? '',
      userName: name,
      createdAt: DateTime.parse(json['created_at'] as String),
      isFromMe: userData != null && userData['id'] == currentUserId,
      attachmentUrl: json['attachment_url'] as String?,
    );
  }
}