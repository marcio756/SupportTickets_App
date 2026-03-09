import 'package:flutter/foundation.dart';
import '../models/activity_log.dart';
import '../repositories/activity_log_repository.dart';

/// Manages state for the Activity Logs screen.
class ActivityLogViewModel extends ChangeNotifier {
  final ActivityLogRepository repository;

  List<ActivityLog> _logs = [];
  bool _isLoading = false;
  String? _errorMessage;

  ActivityLogViewModel({required this.repository});

  List<ActivityLog> get logs => _logs;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<void> loadLogs() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await repository.getActivityLogs();
      
      List<dynamic> rawList = [];

      // O ApiResponser do Laravel embrulha o payload dentro de 'data'
      final responseData = response['data'] ?? response;

      // O nosso controller devolve { 'logs': {...paginator...}, 'options': {...} }
      if (responseData is Map && responseData.containsKey('logs')) {
        final logsData = responseData['logs'];
        
        // O Paginator do Laravel tem a lista real dentro da chave 'data'
        if (logsData is Map && logsData.containsKey('data')) {
          rawList = logsData['data'] as List<dynamic>;
        } else if (logsData is List) {
          rawList = logsData;
        }
      } 
      // Fallback padrão se no futuro o endpoint devolver apenas a paginação direta
      else if (responseData is Map && responseData.containsKey('data')) {
        rawList = responseData['data'] as List<dynamic>;
      } 
      // Fallback se a API devolver uma lista plana diretamente
      else if (responseData is List) {
        rawList = responseData;
      }

      _logs = rawList.map((json) => ActivityLog.fromJson(json as Map<String, dynamic>)).toList();
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}