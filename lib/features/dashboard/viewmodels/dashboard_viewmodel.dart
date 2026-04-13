// Ficheiro: lib/features/dashboard/viewmodels/dashboard_viewmodel.dart
import 'package:flutter/foundation.dart';
import '../repositories/dashboard_repository.dart';

/// Centralizes and manages state for the Dashboard UI
class DashboardViewModel extends ChangeNotifier {
  final DashboardRepository repository;

  Map<String, dynamic> _stats = {};
  List<dynamic> _topCustomers = [];
  List<dynamic> _topSupporters = [];
  String _role = '';
  
  bool _isLoading = false;
  String? _errorMessage;

  DashboardViewModel({required this.repository});

  Map<String, dynamic> get stats => _stats;
  List<dynamic> get topCustomers => _topCustomers;
  List<dynamic> get topSupporters => _topSupporters;
  String get role => _role;
  
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  /// Fetches the dynamic dashboard data based on user role from API
  Future<void> loadDashboardData() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await repository.getDashboardStats(); 
      
      // Safely checks for 'data' wrapper without crashing if response is a List or String
      final data = (response.containsKey('data')) ? response['data'] : response;
      
      if (data is Map) {
        _role = data['role'] ?? 'customer';
        _stats = data['stats'] ?? {};
        
        // Admins and Supporters both have access to Top Customers
        if (_role == 'admin' || _role == 'supporter') {
          _topCustomers = data['top_customers'] ?? [];
        }

        // Only Admins have access to Top Supporters
        if (_role == 'admin') {
          _topSupporters = data['top_supporters'] ?? [];
        }
      }
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}