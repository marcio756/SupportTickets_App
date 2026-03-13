import 'package:flutter/foundation.dart';
import 'package:supporttickets_app/features/vacations/models/vacation_models.dart';
import 'package:supporttickets_app/features/vacations/repositories/vacation_repository.dart';

/// Manages the state for the Vacation Calendar screen.
/// Handles data fetching, loading indicators, and error states.
class VacationCalendarViewModel extends ChangeNotifier {
  final VacationRepository _repository;

  bool _isLoading = false;
  List<VacationTeam> _teams = [];
  String? _errorMessage;

  VacationCalendarViewModel({required VacationRepository repository}) 
      : _repository = repository;

  /// Indicates whether a network request is currently in progress.
  bool get isLoading => _isLoading;

  /// Holds the hierarchical list of teams, members, and vacations.
  List<VacationTeam> get teams => _teams;

  /// Contains a user-friendly error message if the last fetch operation failed.
  /// Null if no errors occurred.
  String? get errorMessage => _errorMessage;

  /// Fetches the vacation calendar data for a specific year and updates the UI state.
  /// * @param year The target year for the calendar.
  Future<void> loadCalendar(int year) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _teams = await _repository.getCalendarData(year: year);
    } catch (e) {
      // In a real scenario, we could log the exact error to a monitoring service here.
      _errorMessage = 'Failed to load vacation calendar. Please try again.';
      _teams = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}