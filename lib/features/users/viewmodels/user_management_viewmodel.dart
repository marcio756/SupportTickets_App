import 'package:flutter/material.dart';
import '../models/user_model.dart';
import '../repositories/user_repository.dart';

/// Orchestrates the state for the User Management feature.
/// Ensures the UI is completely decoupled from API calls and error handling logic.
class UserManagementViewModel extends ChangeNotifier {
  final UserRepository _userRepository;

  List<UserModel> _users = [];
  bool _isLoading = false;
  String? _errorMessage;
  
  String _searchQuery = '';
  String? _selectedRoleFilter;

  List<UserModel> get users => _users;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  String? get selectedRoleFilter => _selectedRoleFilter;

  /// Returns a locally filtered list of users based on search query and role filter.
  List<UserModel> get filteredUsers {
    return _users.where((user) {
      final matchesRole = _selectedRoleFilter == null || 
                          _selectedRoleFilter == 'All' || 
                          user.role == _selectedRoleFilter;
      
      final matchesSearch = _searchQuery.isEmpty ||
          user.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          user.email.toLowerCase().contains(_searchQuery.toLowerCase());
          
      return matchesRole && matchesSearch;
    }).toList();
  }

  UserManagementViewModel({required UserRepository userRepository})
      : _userRepository = userRepository;

  /// Alias to loadUsers to maintain compatibility with existing UI calls.
  Future<void> fetchUsers() async {
    await loadUsers();
  }

  /// Fetches the initial list of users and notifies listeners to render.
  Future<void> loadUsers() async {
    _setLoading(true);
    try {
      _users = await _userRepository.getUsers();
      _errorMessage = null;
    } catch (e) {
      _errorMessage = 'Failed to load users: ${e.toString()}';
    } finally {
      _setLoading(false);
    }
  }

  /// Unified method to handle both creation and updates from the UI.
  Future<bool> saveUser(Map<String, dynamic> userData, {int? id}) async {
    if (id != null) {
      return await updateUser(id, userData);
    } else {
      return await createUser(userData);
    }
  }

  /// Creates a user and optimally inserts it at the top of the local list.
  Future<bool> createUser(Map<String, dynamic> userData) async {
    _setLoading(true);
    try {
      final newUser = await _userRepository.createUser(userData);
      _users.insert(0, newUser);
      _errorMessage = null;
      return true;
    } catch (e) {
      _errorMessage = 'Error creating user: ${e.toString()}';
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// Updates an existing user and replaces the instance in the local list.
  Future<bool> updateUser(int userId, Map<String, dynamic> userData) async {
    _setLoading(true);
    try {
      final updatedUser = await _userRepository.updateUser(userId, userData);
      final index = _users.indexWhere((u) => u.id == userId);
      if (index != -1) {
        _users[index] = updatedUser;
      }
      _errorMessage = null;
      return true;
    } catch (e) {
      _errorMessage = 'Error updating user: ${e.toString()}';
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// Deletes a user from the backend and immediately removes it from the local state.
  Future<bool> deleteUser(int userId) async {
    _setLoading(true);
    try {
      await _userRepository.deleteUser(userId);
      _users.removeWhere((u) => u.id == userId);
      _errorMessage = null;
      return true;
    } catch (e) {
      _errorMessage = 'Error deleting user: ${e.toString()}';
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// Updates the current role filter and triggers a UI rebuild.
  void setRoleFilter(String? role) {
    _selectedRoleFilter = role;
    notifyListeners();
  }

  /// Updates the search query string and triggers a UI rebuild.
  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  /// Encapsulates the state mutation and notification trigger.
  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }
}