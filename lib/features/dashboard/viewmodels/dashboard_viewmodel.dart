import 'package:flutter/foundation.dart';
import '../repositories/dashboard_repository.dart';

/// ViewModel responsible for managing the state and business logic of the dashboard.
class DashboardViewModel extends ChangeNotifier {
  final DashboardRepository dashboardRepository;

  bool _isLoading = true;
  bool _isSupportRole = false;
  Map<String, dynamic> _metrics = {};
  List<Map<String, dynamic>> _topClients = [];
  String? _errorMessage;

  DashboardViewModel({required this.dashboardRepository});

  bool get isLoading => _isLoading;
  bool get isSupportRole => _isSupportRole;
  Map<String, dynamic> get metrics => _metrics;
  List<Map<String, dynamic>> get topClients => _topClients;
  String? get errorMessage => _errorMessage;

  /// Fetches the dashboard data from the API and infers the user role.
  Future<void> loadDashboardData() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final data = await dashboardRepository.getDashboardStats();
      
      _metrics = data;
      _isSupportRole = data.containsKey('active_tickets');

      if (_isSupportRole && data.containsKey('top_clients')) {
        final List<dynamic> rawClients = data['top_clients'];
        _topClients = rawClients.map((client) => client as Map<String, dynamic>).toList();
      }
      
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}