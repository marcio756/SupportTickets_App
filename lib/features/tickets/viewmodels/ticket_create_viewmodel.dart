import 'package:flutter/foundation.dart';
import '../repositories/ticket_repository.dart';

/// ViewModel responsible for managing the state and business logic of creating a new ticket.
class TicketCreateViewModel extends ChangeNotifier {
  final TicketRepository ticketRepository;

  bool _isLoading = false;
  bool _isSuccess = false;
  String? _errorMessage;

  /// Initializes the ViewModel.
  TicketCreateViewModel({required this.ticketRepository});

  bool get isLoading => _isLoading;
  bool get isSuccess => _isSuccess;
  String? get errorMessage => _errorMessage;

  /// Attempts to create a new ticket.
  /// 
  /// Validates the input and updates the state accordingly.
  Future<void> createTicket(String title, String description) async {
    // 1. Basic validation
    if (title.trim().isEmpty || description.trim().isEmpty) {
      _errorMessage = 'O título e a descrição são obrigatórios.';
      notifyListeners();
      return;
    }

    // 2. Start loading state
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    // 3. API Call
    try {
      await ticketRepository.createTicket(title.trim(), description.trim());
      _isSuccess = true;
    } catch (e) {
      _errorMessage = 'Erro ao criar ticket: ${e.toString().replaceAll('Exception: ', '')}';
      _isSuccess = false;
    } finally {
      // 4. End loading state
      _isLoading = false;
      notifyListeners();
    }
  }
}