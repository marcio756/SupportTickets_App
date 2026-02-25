import 'package:flutter/foundation.dart';
import '../models/ticket.dart';
import '../repositories/ticket_repository.dart';

/// ViewModel responsible for managing the state of the ticket list.
/// It separates the business logic and state management from the UI components.
class TicketListViewModel extends ChangeNotifier {
  /// The repository used to fetch ticket data.
  final TicketRepository ticketRepository;

  List<Ticket> _tickets = [];
  bool _isLoading = false;
  String? _errorMessage;

  /// Initializes the ViewModel with the required repository.
  TicketListViewModel({required this.ticketRepository});

  /// The current list of loaded tickets.
  List<Ticket> get tickets => _tickets;

  /// Indicates whether a network request is currently in progress.
  bool get isLoading => _isLoading;

  /// Holds the error message if the last operation failed. Null if successful.
  String? get errorMessage => _errorMessage;

  /// Fetches the tickets from the repository and notifies listeners of state changes.
  Future<void> loadTickets() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _tickets = await ticketRepository.getTickets();
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}