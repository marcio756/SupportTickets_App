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
      _customers = [];
    } finally {
      _isLoadingCustomers = false;
      notifyListeners();
    }
  }

  /// Attempts to create a new ticket, processing either a registered customer or an external email.
  Future<void> createTicket(String title, String description, {String? senderEmail}) async {
    if (title.trim().isEmpty || description.trim().isEmpty) {
      _errorMessage = 'The title and description are required.';
      notifyListeners();
      return;
    }

    // Logic validation for Support Agents: Needs either a Customer OR an External Email, but not both.
    if (_customers.isNotEmpty) {
      bool hasCustomer = _selectedCustomerId != null;
      bool hasEmail = senderEmail != null && senderEmail.trim().isNotEmpty;

      if (!hasCustomer && !hasEmail) {
        _errorMessage = 'Please select a customer OR provide an external email address.';
        notifyListeners();
        return;
      }

      if (hasCustomer && hasEmail) {
        _errorMessage = 'Please select ONLY ONE: a registered customer OR an external email.';
        notifyListeners();
        return;
      }
    }

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await ticketRepository.createTicket(
        title.trim(), 
        description.trim(),
        customerId: _selectedCustomerId,
        senderEmail: senderEmail?.trim(),
      );
      _isSuccess = true;
    } catch (e) {
      _errorMessage = 'Error creating ticket: ${e.toString().replaceAll('Exception: ', '')}';
      _isSuccess = false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}