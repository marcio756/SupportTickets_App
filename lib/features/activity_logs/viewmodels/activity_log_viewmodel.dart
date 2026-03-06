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
      
      // Handle potential pagination structures from Laravel ApiResponser
      final data = response.containsKey('data') ? response['data'] : response;
      final List<dynamic> rawList = data is Map && data.containsKey('data') ? data['data'] : data;
      
      _logs = rawList.map((json) => ActivityLog.fromJson(json as Map<String, dynamic>)).toList();
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}