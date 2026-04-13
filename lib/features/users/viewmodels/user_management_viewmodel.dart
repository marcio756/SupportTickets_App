// Ficheiro: lib/features/users/viewmodels/user_management_viewmodel.dart
import 'dart:async';
import 'package:flutter/material.dart';
import '../models/user_model.dart';
import '../repositories/user_repository.dart';
import '../../profile/repositories/profile_repository.dart';

/// Orchestrates the state for the User Management feature.
/// Handles Infinite Scrolling, Role Filtering, and Server-Side Pagination.
class UserManagementViewModel extends ChangeNotifier {
  final UserRepository _userRepository;
  final ProfileRepository _profileRepository;

  final List<UserModel> _users = [];
  bool _isLoading = false;
  bool _isLoadingMore = false;
  String? _errorMessage;
  
  String _searchQuery = '';
  String? _selectedRoleFilter;
  String? _currentUserRole;

  int _currentPage = 1;
  bool _hasMore = true;
  Timer? _debounceTimer;

  List<UserModel> get users => _users;
  bool get isLoading => _isLoading;
  bool get isLoadingMore => _isLoadingMore;
  bool get hasMore => _hasMore;
  String? get errorMessage => _errorMessage;
  String? get selectedRoleFilter => _selectedRoleFilter;
  
  /// Boolean helper to check if the active user is a supporter
  bool get isSupporter => _currentUserRole?.toLowerCase() == 'supporter';

  UserManagementViewModel({
    required UserRepository userRepository,
    required ProfileRepository profileRepository,
  }) : _userRepository = userRepository,
       _profileRepository = profileRepository;

  /// Loads users with robust state handling for reset or next-page scenarios.
  Future<void> loadUsers({bool reset = false}) async {
    if (reset) {
      _currentPage = 1;
      _hasMore = true;
      _users.clear();
      _errorMessage = null;
      
      // Fetch user profile role only on initial load if not present
      if (_currentUserRole == null) {
        try {
          final profile = await _profileRepository.getProfile();
          final profileData = profile.containsKey('data') ? profile['data'] : profile;
          _currentUserRole = profileData?['role']?.toString();
        } catch (_) {}
      }
      
      _setLoading(true);
    } else {
      if (!_hasMore || _isLoading || _isLoadingMore) return;
      _isLoadingMore = true;
      notifyListeners();
    }

    try {
      final roleToFetch = isSupporter ? 'customer' : (_selectedRoleFilter ?? '');
      
      final response = await _userRepository.getPaginatedUsers(
        page: _currentPage,
        query: _searchQuery,
        role: roleToFetch,
      );

      final dataWrapper = response.containsKey('data') ? response['data'] : response;
      // Depending on API, users list may be wrapped again
      final List<dynamic> usersJson = (dataWrapper is Map && dataWrapper.containsKey('data')) 
          ? dataWrapper['data'] 
          : (dataWrapper is List ? dataWrapper : []);
          
      final newUsers = usersJson.map((json) => UserModel.fromJson(json as Map<String, dynamic>)).toList();

      _users.addAll(newUsers);

      final currentPageData = dataWrapper is Map ? (dataWrapper['current_page'] as int?) : null;
      final lastPageData = dataWrapper is Map ? (dataWrapper['last_page'] as int?) : null;
      
      // If Laravel uses simplePaginate, last_page might be null, but next_page_url indicates presence
      if (dataWrapper is Map && dataWrapper.containsKey('next_page_url')) {
        _hasMore = dataWrapper['next_page_url'] != null;
      } else if (currentPageData != null && lastPageData != null) {
        _hasMore = currentPageData < lastPageData;
      } else {
        _hasMore = newUsers.isNotEmpty; // Fallback
      }

      if (_hasMore) {
        _currentPage++;
      }
      _errorMessage = null;
    } catch (e) {
      _errorMessage = 'Failed to load users: ${e.toString().replaceAll('Exception: ', '')}';
    } finally {
      _isLoading = false;
      _isLoadingMore = false;
      notifyListeners();
    }
  }

  /// Alias for backward compatibility
  Future<void> fetchUsers() async {
    await loadUsers(reset: true);
  }

  /// Triggered from the UI when user scrolls to the bottom
  Future<void> loadMoreUsers() async {
    await loadUsers(reset: false);
  }

  /// Updates the search query with Debounce logic to avoid API spam.
  void setSearchQuery(String query) {
    if (_debounceTimer?.isActive ?? false) _debounceTimer!.cancel();
    
    _debounceTimer = Timer(const Duration(milliseconds: 500), () {
      if (_searchQuery == query) return;
      _searchQuery = query;
      loadUsers(reset: true);
    });
  }

  /// Updates the current role filter and re-fetches from page 1.
  void setRoleFilter(String? role) {
    if (_selectedRoleFilter == role) return;
    _selectedRoleFilter = role;
    loadUsers(reset: true);
  }

  /// Unified method to handle both creation and updates from the UI.
  Future<bool> saveUser(Map<String, dynamic> userData, {int? id}) async {
    if (isSupporter) {
      userData['role'] = 'customer';
    }

    if (id != null) {
      return await updateUser(id, userData);
    } else {
      return await createUser(userData);
    }
  }

  Future<bool> createUser(Map<String, dynamic> userData) async {
    _setLoading(true);
    try {
      final newUser = await _userRepository.createUser(userData);
      _users.insert(0, newUser);
      _errorMessage = null;
      return true;
    } catch (e) {
      _errorMessage = 'Error creating user: ${e.toString().replaceAll('Exception: ', '')}';
      return false;
    } finally {
      _setLoading(false);
    }
  }

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
      _errorMessage = 'Error updating user: ${e.toString().replaceAll('Exception: ', '')}';
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> deleteUser(int userId) async {
    _setLoading(true);
    try {
      await _userRepository.deleteUser(userId);
      _users.removeWhere((u) => u.id == userId);
      _errorMessage = null;
      return true;
    } catch (e) {
      _errorMessage = 'Error deleting user: ${e.toString().replaceAll('Exception: ', '')}';
      return false;
    } finally {
      _setLoading(false);
    }
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    super.dispose();
  }
}