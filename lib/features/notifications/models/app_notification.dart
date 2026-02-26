import 'dart:convert';

class AppNotification {
  final String id;
  final String type;
  final Map<String, dynamic> data;
  final bool isRead;
  final DateTime createdAt;

  AppNotification({
    required this.id,
    required this.type,
    required this.data,
    required this.isRead,
    required this.createdAt,
  });

  factory AppNotification.fromJson(Map<String, dynamic> json) {
    Map<String, dynamic> parsedData = {};
    
    // O Laravel às vezes envia o data como String JSON, outras como Map associativo
    if (json['data'] != null) {
      if (json['data'] is Map) {
        parsedData = Map<String, dynamic>.from(json['data']);
      } else if (json['data'] is String) {
        try {
          parsedData = jsonDecode(json['data']);
        } catch (_) {}
      }
    }

    return AppNotification(
      id: json['id']?.toString() ?? 'unknown_id',
      type: json['type']?.toString() ?? 'unknown_type',
      data: parsedData,
      isRead: json['read_at'] != null,
      createdAt: json['created_at'] != null 
          ? DateTime.tryParse(json['created_at'].toString()) ?? DateTime.now() 
          : DateTime.now(),
    );
  }
}