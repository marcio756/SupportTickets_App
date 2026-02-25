import 'package:flutter/foundation.dart';
import '../repositories/ticket_repository.dart';

/// ViewModel responsible for managing the state and business logic of creating a new ticket.
class TicketCreateViewModel extends ChangeNotifier {
  final TicketRepository ticketRepository;

  bool _isLoading = false;
  bool _isLoadingCustomers = true;
  bool _isSuccess = false;
  String? _errorMessage;

  List<Map<String, dynamic>> _customers = [];
  int? _selectedCustomerId;

  /// Initializes the ViewModel and automatically fetches customers.
  TicketCreateViewModel({required this.ticketRepository}) {
    _loadCustomers();
  }

  bool get isLoading => _isLoading;
  bool get isLoadingCustomers => _isLoadingCustomers;
  bool get isSuccess => _isSuccess;
  String? get errorMessage => _errorMessage;
  List<Map<String, dynamic>> get customers => _customers;
  int? get selectedCustomerId => _selectedCustomerId;

  /// Sets the currently selected customer ID.
  /// 
  /// [id] The ID of the selected customer.
  void setSelectedCustomer(int? id) {
    _selectedCustomerId = id;
    notifyListeners();
  }

  /// Fetches the list of customers from the API.
  /// 
  /// Fails silently and clears the list if the user has no permissions (e.g., is a normal customer).
  Future<void> _loadCustomers() async {
    try {
      _isLoadingCustomers = true;
      notifyListeners();
      
      _customers = await ticketRepository.getCustomers();
    } catch (e) {
      // Se falhar (ex: utilizador não é support), apenas limpamos a lista.
      _customers = [];
    } finally {
      _isLoadingCustomers = false;
      notifyListeners();
    }
  }

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

    if (_customers.isNotEmpty && _selectedCustomerId == null) {
      _errorMessage = 'Por favor, selecione um cliente para o ticket.';
      notifyListeners();
      return;
    }

    // 2. Start loading state
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    // 3. API Call
    try {
      await ticketRepository.createTicket(
        title.trim(), 
        description.trim(),
        customerId: _selectedCustomerId,
      );
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