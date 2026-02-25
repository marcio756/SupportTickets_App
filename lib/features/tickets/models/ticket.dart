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
    // Tenta extrair a descrição tanto da chave 'description' como 'message' (dependendo do endpoint)
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
      
      // Mapeia os dados do cliente
      customerName: json['customer']?['name'] as String?,
      customerId: json['customer']?['id'] as int?,
      
      // Lê os dados do suporte a partir da chave 'support' que agora já virá preenchida pela API
      assigneeName: json['support']?['name'] as String?,
      assigneeId: json['support']?['id'] as int?,
    );
  }
}