import 'package:flutter/foundation.dart';
import '../models/vacation_request.dart';
import '../repositories/vacation_repository.dart';

/// Centralizes UI state for the vacations feature.
/// Notifies listeners (UI) whenever data fetching starts, completes, or fails.
class VacationViewModel extends ChangeNotifier {
  final VacationRepository repository;

  List<VacationRequest> _vacations = [];
  bool _isLoading = false;
  String? _errorMessage;

  VacationViewModel({required this.repository});

  List<VacationRequest> get vacations => _vacations;
  bool get isLoading => _isLoading;
  bool get hasError => _errorMessage != null;
  String? get errorMessage => _errorMessage;

  /// Loads the initial dataset for the user, managing loading flags around the async call.
  Future<void> loadVacations(String userId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _vacations = await repository.fetchVacations(userId);
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Pushes a new request to the repository and updates the local state upon success.
  Future<bool> submitRequest(VacationRequest request) async {
    _isLoading = true;
    notifyListeners();

    try {
      final newVacation = await repository.createVacationRequest(request);
      _vacations.add(newVacation);
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Attempts to cancel a pending request via API and reflects the deletion locally.
  Future<bool> cancelRequest(String vacationId) async {
    _isLoading = true;
    notifyListeners();

    try {
      await repository.cancelVacationRequest(vacationId);
      _vacations.removeWhere((v) => v.id == vacationId);
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}