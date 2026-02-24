/// Represents a support ticket entity within the application.
/// It holds the core data needed to display and manage a user's request.
class Ticket {
  /// Unique identifier of the ticket.
  final int id;
  
  /// The brief title or subject of the support request.
  final String title;
  
  /// The detailed explanation of the issue.
  final String description;
  
  /// The current state of the ticket (e.g., 'open', 'closed', 'in_progress').
  final String status;
  
  /// The timestamp of when the ticket was created.
  final DateTime createdAt;

  /// Constructs a new [Ticket] instance.
  Ticket({
    required this.id,
    required this.title,
    required this.description,
    required this.status,
    required this.createdAt,
  });

  /// Factory constructor to securely map a dynamic JSON payload into a typed [Ticket] object.
  /// 
  /// [json] The map containing key-value pairs from the API response.
  factory Ticket.fromJson(Map<String, dynamic> json) {
    return Ticket(
      id: json['id'] as int,
      title: json['title'] as String? ?? 'No Title',
      description: json['description'] as String? ?? 'No Description provided.',
      status: json['status'] as String? ?? 'open',
      createdAt: json['created_at'] != null 
          ? DateTime.parse(json['created_at'] as String) 
          : DateTime.now(),
    );
  }
}