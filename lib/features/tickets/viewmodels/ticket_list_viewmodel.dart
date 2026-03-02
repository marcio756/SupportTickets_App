import 'package:flutter/foundation.dart';
import '../models/ticket.dart';
import '../repositories/ticket_repository.dart';

/// ViewModel responsible for managing the state of the ticket list and active filters.
/// It separates the business logic and state management from the UI components.
class TicketListViewModel extends ChangeNotifier {
  /// The repository used to fetch ticket data.
  final TicketRepository ticketRepository;

  List<Ticket> _tickets = [];
  bool _isLoading = false;
  String? _errorMessage;

  // Filter States
  String _searchQuery = '';
  String? _statusFilter;
  int? _customerFilter;
  String? _assigneeFilter;
  int? _tagFilter;
  
  List<Map<String, dynamic>> _customers = [];
  List<Map<String, dynamic>> _tags = [];

  /// Initializes the ViewModel with the required repository and loads metadata (customers and tags) if applicable.
  TicketListViewModel({required this.ticketRepository}) {
    _loadCustomers();
    _loadTags();
  }

  /// The current list of loaded tickets.
  List<Ticket> get tickets => _tickets;

  /// Indicates whether a network request is currently in progress.
  bool get isLoading => _isLoading;

  /// Holds the error message if the last operation failed. Null if successful.
  String? get errorMessage => _errorMessage;

  // Getters for filters
  String get searchQuery => _searchQuery;
  String? get statusFilter => _statusFilter;
  int? get customerFilter => _customerFilter;
  String? get assigneeFilter => _assigneeFilter;
  int? get tagFilter => _tagFilter;
  
  List<Map<String, dynamic>> get customers => _customers;
  List<Map<String, dynamic>> get tags => _tags;

  /// Updates the search query and triggers a reload.
  void setSearchQuery(String query) {
    _searchQuery = query;
    loadTickets();
  }

  /// Updates the status filter without automatically triggering a reload.
  void setStatusFilter(String? status) {
    _statusFilter = status;
    notifyListeners();
  }

  /// Updates the customer filter without automatically triggering a reload.
  void setCustomerFilter(int? customerId) {
    _customerFilter = customerId;
    notifyListeners();
  }

  /// Updates the assignee filter without automatically triggering a reload.
  void setAssigneeFilter(String? assignee) {
    _assigneeFilter = assignee;
    notifyListeners();
  }

  /// Updates the tag filter without automatically triggering a reload.
  void setTagFilter(int? tagId) {
    _tagFilter = tagId;
    notifyListeners();
  }

  /// Clears all active filters and reloads the ticket list.
  void clearFilters() {
    _searchQuery = '';
    _statusFilter = null;
    _customerFilter = null;
    _assigneeFilter = null;
    _tagFilter = null;
    loadTickets();
  }

  /// Fetches the list of customers for filtering. 
  /// Fails silently if the user is not a supporter.
  Future<void> _loadCustomers() async {
    try {
      _customers = await ticketRepository.getCustomers();
      notifyListeners();
    } catch (_) {
      _customers = [];
    }
  }

  /// Fetches the list of tags for filtering. 
  /// Fails silently if the user is not a supporter or tags are unavailable.
  Future<void> _loadTags() async {
    try {
      _tags = await ticketRepository.getTags();
      notifyListeners();
    } catch (_) {
      _tags = [];
    }
  }

  /// Compiles active filters into a map suitable for API query parameters.
  Map<String, dynamic> _buildFilterMap() {
    return {
      if (_searchQuery.trim().isNotEmpty) 'search': _searchQuery.trim(),
      if (_statusFilter != null) 'status': _statusFilter,
      if (_customerFilter != null) 'customers': _customerFilter.toString(),
      if (_assigneeFilter != null) 'assignees': _assigneeFilter,
      if (_tagFilter != null) 'tags': _tagFilter.toString(),
    };
  }

  /// Fetches the tickets from the repository applying the current filters.
  Future<void> loadTickets() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _tickets = await ticketRepository.getTickets(filters: _buildFilterMap());
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Deletes a specific ticket and removes it from the local state.
  Future<bool> deleteTicket(int ticketId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await ticketRepository.deleteTicket(ticketId);
      _tickets.removeWhere((ticket) => ticket.id == ticketId);
      return true;
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}