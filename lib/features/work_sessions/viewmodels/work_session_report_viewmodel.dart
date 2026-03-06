import 'package:flutter/foundation.dart';
import '../repositories/work_session_repository.dart';

/// Manages the state for the Work Session Reports screen.
/// 
/// Handles pagination, data fetching, and filtering (by user or date).
class WorkSessionReportViewModel extends ChangeNotifier {
  final WorkSessionRepository _repository;

  bool _isLoading = false;
  bool _isLoadingMore = false;
  String? _errorMessage;
  
  List<dynamic> _sessions = [];
  List<dynamic> _usersList = [];
  Map<String, dynamic> _summary = {'total_hours': 0, 'total_minutes': 0};
  
  int _currentPage = 1;
  bool _hasMore = true;

  String? _selectedUserId;
  DateTime? _selectedDate;

  WorkSessionReportViewModel({required WorkSessionRepository repository}) : _repository = repository;

  bool get isLoading => _isLoading;
  bool get isLoadingMore => _isLoadingMore;
  String? get errorMessage => _errorMessage;
  List<dynamic> get sessions => _sessions;
  List<dynamic> get usersList => _usersList;
  Map<String, dynamic> get summary => _summary;
  String? get selectedUserId => _selectedUserId;
  DateTime? get selectedDate => _selectedDate;
  bool get hasMore => _hasMore;

  /// Fetches the initial page of reports based on current filters.
  Future<void> loadReports() async {
    _isLoading = true;
    _errorMessage = null;
    _currentPage = 1;
    _hasMore = true;
    notifyListeners();

    try {
      final dateStr = _selectedDate != null 
          ? "${_selectedDate!.year}-${_selectedDate!.month.toString().padLeft(2, '0')}-${_selectedDate!.day.toString().padLeft(2, '0')}" 
          : null;

      final response = await _repository.getReports(
        page: _currentPage,
        userId: _selectedUserId,
        date: dateStr,
      );

      final data = response['data'] ?? response;
      
      _sessions = data['sessions']['data'] ?? [];
      _usersList = data['users'] ?? [];
      _summary = data['summary'] ?? {'total_hours': 0, 'total_minutes': 0};
      
      final currentPage = data['sessions']['current_page'] as int;
      final lastPage = data['sessions']['last_page'] as int;
      _hasMore = currentPage < lastPage;

    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Appends the next page of reports to the existing list.
  Future<void> loadMore() async {
    if (_isLoading || _isLoadingMore || !_hasMore) return;

    _isLoadingMore = true;
    notifyListeners();

    try {
      _currentPage++;
      final dateStr = _selectedDate != null 
          ? "${_selectedDate!.year}-${_selectedDate!.month.toString().padLeft(2, '0')}-${_selectedDate!.day.toString().padLeft(2, '0')}" 
          : null;

      final response = await _repository.getReports(
        page: _currentPage,
        userId: _selectedUserId,
        date: dateStr,
      );

      final data = response['data'] ?? response;
      final newSessions = data['sessions']['data'] ?? [];
      
      _sessions.addAll(newSessions);
      
      final currentPage = data['sessions']['current_page'] as int;
      final lastPage = data['sessions']['last_page'] as int;
      _hasMore = currentPage < lastPage;

    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
    } finally {
      _isLoadingMore = false;
      notifyListeners();
    }
  }

  /// Updates the active filters and resets the list.
  void setFilters({String? userId, DateTime? date}) {
    _selectedUserId = userId;
    _selectedDate = date;
    loadReports();
  }

  /// Clears all applied filters.
  void clearFilters() {
    _selectedUserId = null;
    _selectedDate = null;
    loadReports();
  }
}