// Ficheiro: lib/features/announcements/viewmodels/announcement_viewmodel.dart
import 'package:flutter/material.dart';
import '../models/announcement.dart';
import '../repositories/announcement_repository.dart';
import '../../profile/repositories/profile_repository.dart';

/// Manages the state and pagination for the Announcements module.
class AnnouncementViewModel extends ChangeNotifier {
  final AnnouncementRepository _repository;
  final ProfileRepository _profileRepository;

  final List<Announcement> _announcements = [];
  bool _isLoading = false;
  bool _isLoadingMore = false;
  bool _hasMore = true;
  int _currentPage = 1;
  String? _errorMessage;
  bool _canCreate = false;
  
  // Customer Pagination & Search State
  final List<Map<String, dynamic>> _customers = [];
  bool _isCustomersLoading = false;
  bool _isCustomersLoadingMore = false;
  bool _customersHasMore = true;
  int _customersPage = 1;
  String _customerSearchQuery = '';

  List<Announcement> get announcements => _announcements;
  bool get isLoading => _isLoading;
  bool get isLoadingMore => _isLoadingMore;
  bool get hasMore => _hasMore;
  String? get errorMessage => _errorMessage;
  bool get canCreate => _canCreate;
  
  List<Map<String, dynamic>> get customers => _customers;
  bool get isCustomersLoading => _isCustomersLoading;
  bool get isCustomersLoadingMore => _isCustomersLoadingMore;

  AnnouncementViewModel({
    required AnnouncementRepository repository,
    required ProfileRepository profileRepository,
  }) : _repository = repository,
       _profileRepository = profileRepository;

  /// Loads announcements, supporting pagination.
  Future<void> loadAnnouncements({bool reset = false}) async {
    if (reset) {
      _currentPage = 1;
      _hasMore = true;
      _announcements.clear();
      _errorMessage = null;
      _setLoading(true);

      try {
        final profile = await _profileRepository.getProfile();
        final profileData = profile.containsKey('data') ? profile['data'] : profile;
        final userRole = profileData?['role']?.toString().toLowerCase();
        _canCreate = userRole == 'admin' || userRole == 'supporter';
      } catch (_) {}
    } else {
      if (!_hasMore || _isLoading || _isLoadingMore) return;
      _isLoadingMore = true;
      notifyListeners();
    }

    try {
      final response = await _repository.getAnnouncements(page: _currentPage);
      final dataWrapper = response.containsKey('data') ? response['data'] : response;
      final List<dynamic> jsonList = (dataWrapper is Map && dataWrapper.containsKey('data')) 
          ? dataWrapper['data'] 
          : (dataWrapper is List ? dataWrapper : []);

      final newItems = jsonList.map((j) => Announcement.fromJson(j as Map<String, dynamic>)).toList();
      _announcements.addAll(newItems);

      if (dataWrapper is Map && dataWrapper.containsKey('next_page_url')) {
        _hasMore = dataWrapper['next_page_url'] != null;
      } else {
        _hasMore = newItems.isNotEmpty;
      }

      if (_hasMore) _currentPage++;
      _errorMessage = null;
    } catch (e) {
      _errorMessage = 'Failed to load announcements: ${e.toString().replaceAll('Exception: ', '')}';
    } finally {
      _isLoading = false;
      _isLoadingMore = false;
      notifyListeners();
    }
  }

  /// Loads the paginated list of customers, supporting search.
  Future<void> loadCustomers({bool reset = false, String? search}) async {
    if (search != null) {
      _customerSearchQuery = search;
      reset = true;
    }

    if (reset) {
      _customersPage = 1;
      _customersHasMore = true;
      _customers.clear();
      _isCustomersLoading = true;
      notifyListeners();
    } else {
      if (!_customersHasMore || _isCustomersLoading || _isCustomersLoadingMore) return;
      _isCustomersLoadingMore = true;
      notifyListeners();
    }

    try {
      final response = await _repository.getCustomers(
        page: _customersPage,
        search: _customerSearchQuery,
      );

      final dataWrapper = response.containsKey('data') ? response['data'] : response;
      final List<dynamic> jsonList = (dataWrapper is Map && dataWrapper.containsKey('data')) 
          ? dataWrapper['data'] 
          : (dataWrapper is List ? dataWrapper : []);
      
      final newItems = jsonList.cast<Map<String, dynamic>>();
      _customers.addAll(newItems);

      if (dataWrapper is Map && dataWrapper.containsKey('next_page_url')) {
        _customersHasMore = dataWrapper['next_page_url'] != null;
      } else {
        _customersHasMore = newItems.length >= 10;
      }

      if (_customersHasMore) _customersPage++;
    } catch (e) {
      // Falha silenciosa ou registo de erro para a lista de clientes
    } finally {
      _isCustomersLoading = false;
      _isCustomersLoadingMore = false;
      notifyListeners();
    }
  }

  /// Triggers the creation of a new announcement and email dispatch.
  Future<bool> createAnnouncement(String subject, String message, String targetAudience, List<int> customerIds) async {
    _setLoading(true);
    try {
      final newAnn = await _repository.createAnnouncement({
        'subject': subject,
        'message': message,
        'target_audience': targetAudience,
        if (targetAudience == 'specific_customers') 'customer_ids': customerIds,
      });
      _announcements.insert(0, newAnn);
      _errorMessage = null;
      return true;
    } catch (e) {
      _errorMessage = 'Failed to create announcement: ${e.toString().replaceAll('Exception: ', '')}';
      return false;
    } finally {
      _setLoading(false);
    }
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }
}