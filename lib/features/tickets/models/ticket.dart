/// Represents a support ticket domain model.
class Ticket {
  final int id;
  final String title;
  final String description;
  final String status;
  final DateTime createdAt;
  final String? supportTime;
  
  final String? customerName;
  final int? customerId;
  
  final String? assigneeName;
  final int? assigneeId;

  final List<Map<String, dynamic>> tags;

  Ticket({
    required this.id,
    required this.title,
    required this.description,
    required this.status,
    required this.createdAt,
    this.supportTime,
    this.customerName,
    this.customerId,
    this.assigneeName,
    this.assigneeId,
    this.tags = const [],
  });

  /// Factory constructor for creating a Ticket from a JSON map.
  factory Ticket.fromJson(Map<String, dynamic> json) {
    final String description = json['description'] ?? json['message'] as String? ?? 'No description provided';

    return Ticket(
      id: json['id'] as int,
      title: json['title'] as String? ?? 'No Title',
      description: description,
      status: json['status'] as String? ?? 'open',
      createdAt: json['created_at'] != null 
          ? DateTime.parse(json['created_at'] as String) 
          : DateTime.now(),
      supportTime: json['support_time']?.toString(),
      
      customerName: json['customer']?['name'] as String?,
      customerId: json['customer']?['id'] as int?,
      
      assigneeName: json['support']?['name'] as String?,
      assigneeId: json['assigned_to'] as int? ?? json['support']?['id'] as int?,

      tags: (json['tags'] as List<dynamic>?)?.cast<Map<String, dynamic>>() ?? [],
    );
  }

  /// Returns a copy of the ticket with updated fields.
  Ticket copyWith({
    int? id,
    String? title,
    String? description,
    String? status,
    DateTime? createdAt,
    String? supportTime,
    String? customerName,
    int? customerId,
    String? assigneeName,
    int? assigneeId,
    List<Map<String, dynamic>>? tags,
  }) {
    return Ticket(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      supportTime: supportTime ?? this.supportTime,
      customerName: customerName ?? this.customerName,
      customerId: customerId ?? this.customerId,
      assigneeName: assigneeName ?? this.assigneeName,
      assigneeId: assigneeId ?? this.assigneeId,
      tags: tags ?? this.tags,
    );
  }
}