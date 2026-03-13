import 'package:flutter/foundation.dart';
import 'package:supporttickets_app/features/vacations/repositories/vacation_repository.dart';

/// Manages the state and local validation for the Vacation Request Form.
class VacationRequestViewModel extends ChangeNotifier {
  final VacationRepository _repository;

  bool _isLoading = false;
  String? _errorMessage;
  
  DateTime? _startDate;
  DateTime? _endDate;

  VacationRequestViewModel({required VacationRepository repository}) 
      : _repository = repository;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  DateTime? get startDate => _startDate;
  DateTime? get endDate => _endDate;

  /// Updates the start date and clears any previous error messages.
  void setStartDate(DateTime date) {
    _startDate = date;
    _errorMessage = null;
    notifyListeners();
  }

  /// Updates the end date and clears any previous error messages.
  void setEndDate(DateTime date) {
    _endDate = date;
    _errorMessage = null;
    notifyListeners();
  }

  /// Validates the selected dates and attempts to submit the request to the API.
  /// * @return True if the request was successful, false otherwise.
  Future<bool> submitRequest() async {
    if (_startDate == null || _endDate == null) {
      _errorMessage = 'Please select both start and end dates.';
      notifyListeners();
      return false;
    }

    if (_endDate!.isBefore(_startDate!)) {
      _errorMessage = 'The end date cannot be earlier than the start date.';
      notifyListeners();
      return false;
    }

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _repository.bookVacation(
        startDate: _startDate!,
        endDate: _endDate!,
      );
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _isLoading = false;
      // In a real scenario, map ApiException to specific readable messages (e.g., overlapping dates)
      _errorMessage = 'Failed to submit vacation request. Please try again or check your dates.';
      notifyListeners();
      return false;
    }
  }
}