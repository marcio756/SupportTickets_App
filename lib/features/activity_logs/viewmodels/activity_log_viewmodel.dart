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
      _logs = await repository.getLogs();
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}