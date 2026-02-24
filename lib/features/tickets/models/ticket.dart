class Ticket {
  final int id;
  final String title;
  final String description;
  final String status;
  final DateTime createdAt;
  final String? supportTime;

  Ticket({
    required this.id,
    required this.title,
    required this.description,
    required this.status,
    required this.createdAt,
    this.supportTime,
  });

  factory Ticket.fromJson(Map<String, dynamic> json) {
    return Ticket(
      id: json['id'] as int,
      title: json['title'] as String? ?? 'No Title',
      description: json['description'] as String? ?? 'No Description',
      status: json['status'] as String? ?? 'open',
      createdAt: json['created_at'] != null 
          ? DateTime.parse(json['created_at'] as String) 
          : DateTime.now(),
      supportTime: json['support_time'] as String?,
    );
  }
}