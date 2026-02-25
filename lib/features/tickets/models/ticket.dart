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
  });

  factory Ticket.fromJson(Map<String, dynamic> json) {
    // Tries to extract description from both endpoints
    final String description = json['description'] ?? json['message'] as String? ?? 'Sem descrição';

    return Ticket(
      id: json['id'] as int,
      title: json['title'] as String? ?? 'Sem Título',
      description: description,
      status: json['status'] as String? ?? 'open',
      createdAt: json['created_at'] != null 
          ? DateTime.parse(json['created_at'] as String) 
          : DateTime.now(),
      supportTime: json['support_time']?.toString(),
      
      customerName: json['customer']?['name'] as String?,
      customerId: json['customer']?['id'] as int?,
      
      assigneeName: json['support']?['name'] as String?,
      // Reads directly from 'assigned_to' injected in our Laravel API Resource
      assigneeId: json['assigned_to'] as int? ?? json['support']?['id'] as int?,
    );
  }

  /// Creates a copy of this Ticket but with the given fields replaced with the new values.
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
    );
  }
}