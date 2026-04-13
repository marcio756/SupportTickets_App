// Ficheiro: lib/features/tickets/viewmodels/ticket_list_viewmodel.dart
import 'dart:async';
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
  bool _isSyncing = false;
  String? _errorMessage;

  // Pagination States
  int _currentPage = 1;
  bool _hasMore = true;
  bool _isLoadingMore = false;
  static const int _perPageLimit = 15; // Assume-se 15 como o default do Laravel paginate()

  // Filter States
  String _searchQuery = '';
  String? _statusFilter;
  String? _sourceFilter;
  int? _customerFilter;
  String? _assigneeFilter;
  int? _tagFilter;
  
  List<Map<String, dynamic>> _customers = [];
  List<Map<String, dynamic>> _tags = [];

  Timer? _debounceTimer;

  /// Initializes the ViewModel with the required repository and loads metadata (customers and tags) if applicable.
  TicketListViewModel({required this.ticketRepository}) {
    _loadCustomers();
    _loadTags();
  }

  /// The current list of loaded tickets.
  List<Ticket> get tickets => _tickets;

  /// Indicates whether an initial network request is currently in progress.
  bool get isLoading => _isLoading;

  /// Indicates whether we are currently fetching the next page of data.
  bool get isLoadingMore => _isLoadingMore;

  /// Indicates if there are more pages available to fetch from the backend.
  bool get hasMore => _hasMore;

  /// Indicates whether a background synchronization is in progress.
  bool get isSyncing => _isSyncing;

  /// Holds the error message if the last operation failed. Null if successful.
  String? get errorMessage => _errorMessage;

  // Getters for filters
  String get searchQuery => _searchQuery;
  String? get statusFilter => _statusFilter;
  String? get sourceFilter => _sourceFilter;
  int? get customerFilter => _customerFilter;
  String? get assigneeFilter => _assigneeFilter;
  int? get tagFilter => _tagFilter;
  
  List<Map<String, dynamic>> get customers => _customers;
  List<Map<String, dynamic>> get tags => _tags;

  /// Updates the search query using a debounce to prevent excessive API requests, then reloads from page 1.
  void setSearchQuery(String query) {
    if (_debounceTimer?.isActive ?? false) _debounceTimer!.cancel();
    
    _debounceTimer = Timer(const Duration(milliseconds: 500), () {
      if (_searchQuery == query) return;
      _searchQuery = query;
      loadTickets(reset: true);
    });
  }

  /// Updates the status filter and automatically triggers a reload.
  void setStatusFilter(String? status) {
    if (_statusFilter == status) return;
    _statusFilter = status;
    loadTickets(reset: true);
  }

  /// Updates the source filter and automatically triggers a reload.
  void setSourceFilter(String? source) {
    if (_sourceFilter == source) return;
    _sourceFilter = source;
    loadTickets(reset: true);
  }

  /// Updates the customer filter and automatically triggers a reload.
  void setCustomerFilter(int? customerId) {
    if (_customerFilter == customerId) return;
    _customerFilter = customerId;
    loadTickets(reset: true);
  }

  /// Updates the assignee filter and automatically triggers a reload.
  void setAssigneeFilter(String? assignee) {
    if (_assigneeFilter == assignee) return;
    _assigneeFilter = assignee;
    loadTickets(reset: true);
  }

  /// Updates the tag filter and automatically triggers a reload.
  void setTagFilter(int? tagId) {
    if (_tagFilter == tagId) return;
    _tagFilter = tagId;
    loadTickets(reset: true);
  }

  /// Clears all active filters and reloads the ticket list from page 1.
  void clearFilters() {
    _searchQuery = '';
    _statusFilter = null;
    _sourceFilter = null;
    _customerFilter = null;
    _assigneeFilter = null;
    _tagFilter = null;
    loadTickets(reset: true);
  }

  Future<void> _loadCustomers() async {
    try {
      _customers = await ticketRepository.getCustomers();
      notifyListeners();
    } catch (_) {
      _customers = [];
    }
  }

  Future<void> _loadTags() async {
    try {
      _tags = await ticketRepository.getTags();
      notifyListeners();
    } catch (_) {
      _tags = [];
    }
  }

  Map<String, dynamic> _buildFilterMap() {
    return {
      if (_searchQuery.trim().isNotEmpty) 'search': _searchQuery.trim(),
      if (_statusFilter != null) 'status': _statusFilter,
      if (_sourceFilter != null) 'source': _sourceFilter,
      if (_customerFilter != null) 'customers': _customerFilter.toString(),
      if (_assigneeFilter != null) 'assignees': _assigneeFilter,
      if (_tagFilter != null) 'tags': _tagFilter.toString(),
    };
  }

  /// Fetches the tickets. If [reset] is true, clears the list and starts from page 1.
  Future<void> loadTickets({bool reset = false}) async {
    if (reset) {
      _currentPage = 1;
      _hasMore = true;
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();
    } else {
      if (!_hasMore || _isLoadingMore || _isLoading) return;
      _isLoadingMore = true;
      notifyListeners();
    }

    try {
      final newTickets = await ticketRepository.getTickets(
        filters: _buildFilterMap(),
        page: _currentPage,
      );

      if (reset) {
        _tickets = newTickets;
      } else {
        _tickets.addAll(newTickets);
      }

      // If the backend returns fewer items than the limit, we've reached the end
      if (newTickets.length < _perPageLimit) {
        _hasMore = false;
      } else {
        _currentPage++;
      }
      
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      // If fetching the first page fails, we stop hasMore to prevent infinite error loops
      if (reset) _hasMore = false; 
    } finally {
      _isLoading = false;
      _isLoadingMore = false;
      notifyListeners();
    }
  }
  
  /// Syncs emails via IMAP using an illusion progress, and then resets and loads tickets.
  Future<void> syncEmailsAndLoad() async {
    _isSyncing = true;
    notifyListeners();

    try {
      await ticketRepository.fetchEmails();
    } catch (_) {
      // Intentionally silent
    }

    await loadTickets(reset: true);
    
    _isSyncing = false;
    notifyListeners();
  }

  /// Deletes a specific ticket using an Optimistic UI approach.
  Future<bool> deleteTicket(int ticketId) async {
    final int index = _tickets.indexWhere((ticket) => ticket.id == ticketId);
    if (index == -1) return false;

    final Ticket backupTicket = _tickets[index];

    _tickets.removeAt(index);
    _errorMessage = null;
    notifyListeners();

    try {
      await ticketRepository.deleteTicket(ticketId);
      return true;
    } catch (e) {
      _tickets.insert(index, backupTicket);
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      notifyListeners();
      return false;
    }
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    super.dispose();
  }
}