import 'package:flutter/foundation.dart';
import '../repositories/user_repository.dart';

class UserManagementViewModel extends ChangeNotifier {
  final UserRepository userRepository;

  bool _isLoading = false;
  String _searchQuery = '';
  String _selectedRoleFilter = 'all';
  List<Map<String, dynamic>> _users = [];
  String? _errorMessage;

  UserManagementViewModel({required this.userRepository});

  bool get isLoading => _isLoading;
  String get searchQuery => _searchQuery;
  String get selectedRoleFilter => _selectedRoleFilter;
  List<Map<String, dynamic>> get users => _users;
  String? get errorMessage => _errorMessage;

  void setSearchQuery(String query) {
    _searchQuery = query;
    fetchUsers();
  }

  void setRoleFilter(String role) {
    _selectedRoleFilter = role;
    fetchUsers();
  }

  Future<void> fetchUsers() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await userRepository.getUsers(
        query: _searchQuery,
        role: _selectedRoleFilter,
      );
      final data = response['data'] as List<dynamic>?;
      if (data != null) {
        _users = data.map((e) => e as Map<String, dynamic>).toList();
      }
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> saveUser({String? id, required Map<String, dynamic> data}) async {
    _isLoading = true;
    notifyListeners();
    try {
      if (id == null) {
        await userRepository.createUser(data);
      } else {
        await userRepository.updateUser(id, data);
      }
      await fetchUsers();
      return true;
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> deleteUser(String id) async {
    _isLoading = true;
    notifyListeners();
    try {
      await userRepository.deleteUser(id);
      await fetchUsers();
      return true;
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }
}