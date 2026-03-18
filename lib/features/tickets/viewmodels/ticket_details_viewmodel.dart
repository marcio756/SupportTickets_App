import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:file_picker/file_picker.dart';
import '../models/ticket.dart';
import '../models/ticket_message.dart';
import '../repositories/ticket_repository.dart';
import '../../profile/repositories/profile_repository.dart';
import '../../users/repositories/user_repository.dart';

/// ViewModel responsible for managing the state and logic of a specific ticket's details.
class TicketDetailsViewModel extends ChangeNotifier {
  final TicketRepository ticketRepository;
  final ProfileRepository profileRepository;
  
  Ticket ticket;

  List<TicketMessage> _messages = [];
  List<Map<String, dynamic>> _availableTags = [];
  List<Map<String, dynamic>> _mentionableUsers = [];
  
  bool _isLoading = false;
  bool _isSending = false;
  bool _isUpdatingStatus = false;
  bool _isClaiming = false;
  String? _errorMessage;
  int? _currentUserId;
  String? _currentUserRole;

  Timer? _supportTimer;

  TicketDetailsViewModel({
    required this.ticketRepository,
    required this.profileRepository,
    required this.ticket,
  });

  List<TicketMessage> get messages => _messages;
  List<Map<String, dynamic>> get availableTags => _availableTags;
  List<Map<String, dynamic>> get mentionableUsers => _mentionableUsers;
  
  bool get isLoading => _isLoading;
  bool get isSending => _isSending;
  bool get isUpdatingStatus => _isUpdatingStatus;
  bool get isClaiming => _isClaiming;
  String? get errorMessage => _errorMessage;
  int? get currentUserId => _currentUserId;
  
  // Role Definitions
  bool get isStaff => _currentUserRole == 'supporter' || _currentUserRole == 'admin';
  bool get isAdmin => _currentUserRole == 'admin';

  /// Check explicit write permissions based on assignments or mentions
  bool get hasWritePermission {
    if (!isStaff) return false;
    if (isAdmin) return true;
    if (ticket.assigneeId == _currentUserId) return true;
    if (ticket.participants.any((p) => p['id'] == _currentUserId)) return true;
    return false;
  }

  @override
  void dispose() {
    _supportTimer?.cancel();
    super.dispose();
  }

  Future<void> initialize() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final profileResponse = await profileRepository.getProfile();
      final profileData = profileResponse.containsKey('data') ? profileResponse['data'] : profileResponse;
      
      if (profileData != null) {
        if (profileData['id'] != null) _currentUserId = int.tryParse(profileData['id'].toString());
        if (profileData['role'] != null) _currentUserRole = profileData['role'].toString();
      }

      // Load Tags and Mentionable Users if Staff
      if (isStaff) {
        _availableTags = await ticketRepository.getTags();
        
        final userRepo = UserRepository(apiClient: ticketRepository.apiClient);
        
        // Fetch all users and filter locally to avoid hitting undefined specific endpoints
        final allUsers = await userRepo.getUsers();
        final staffMembers = allUsers.where((u) => u.role == 'supporter' || u.role == 'admin');
        
        // Explicitly casting the Map to <String, dynamic> to prevent Dart type inference errors
        _mentionableUsers = staffMembers.map<Map<String, dynamic>>((u) => <String, dynamic>{
          'id': u.id.toString(), 
          'name': u.name, 
          'role': u.role
        }).toList();
      }

      // Inject the Ticket's Customer or External Email into the mentionable list
      if (ticket.customerName != null && ticket.customerId != null) {
         if (!_mentionableUsers.any((u) => u['id'] == ticket.customerId.toString())) {
           _mentionableUsers.add(<String, dynamic>{
             'id': ticket.customerId.toString(), 
             'name': ticket.customerName, 
             'role': 'customer'
           });
         }
      } else if (ticket.senderEmail != null) {
         _mentionableUsers.add(<String, dynamic>{
           'id': ticket.senderEmail, 
           'name': ticket.senderEmail, 
           'role': 'customer'
         });
      }

      await loadMessages();
    } catch (e) {
      _errorMessage = 'Failed to initialize chat: ${e.toString().replaceAll('Exception: ', '')}';
    } finally {
      _isLoading = false;
      _evaluateTimer(); 
      notifyListeners();
    }
  }

  Future<void> loadMessages() async {
    try {
      _messages = await ticketRepository.getTicketMessages(ticket.id, _currentUserId);
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Failed to load messages: ${e.toString().replaceAll('Exception: ', '')}';
      notifyListeners();
    }
  }

  /// Sends a message using Optimistic UI principles.
  Future<bool> sendMessage(String? messageText, {PlatformFile? attachment, List<String>? mentions}) async {
    if ((messageText == null || messageText.trim().isEmpty) && attachment == null) return false;

    final tempJson = {
      'id': -(DateTime.now().millisecondsSinceEpoch),
      'ticket_id': ticket.id,
      'user_id': _currentUserId,
      'message': messageText ?? '',
      'created_at': DateTime.now().toIso8601String(),
    };
    
    final tempMessage = TicketMessage.fromJson(tempJson, _currentUserId ?? 0);

    _isSending = true;
    _errorMessage = null;
    _messages.add(tempMessage);
    notifyListeners();

    try {
      final realMessage = await ticketRepository.sendMessage(
        ticket.id, 
        messageText, 
        userId: _currentUserId,
        attachment: attachment,
        mentions: mentions,
      );
      
      _messages.removeWhere((m) => m.id == tempMessage.id);
      _messages.add(realMessage);
      
      return true;
    } catch (e) {
      _messages.removeWhere((m) => m.id == tempMessage.id);
      _errorMessage = 'Failed to send message: ${e.toString().replaceAll('Exception: ', '')}';
      return false;
    } finally {
      _isSending = false;
      notifyListeners();
    }
  }

  Future<void> updateStatus(String newStatus) async {
    final String oldStatus = ticket.status;
    ticket = ticket.copyWith(status: newStatus);
    _isUpdatingStatus = true;
    _errorMessage = null;
    notifyListeners();

    try {
      ticket = await ticketRepository.updateTicketStatus(ticket.id, newStatus);
    } catch (e) {
      ticket = ticket.copyWith(status: oldStatus);
      _errorMessage = 'Failed to update status: ${e.toString().replaceAll('Exception: ', '')}';
    } finally {
      _isUpdatingStatus = false;
      _evaluateTimer(); 
      notifyListeners();
    }
  }

  Future<void> claimTicket() async {
    _isClaiming = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await ticketRepository.assignTicket(ticket.id, {});
      final updatedData = response.containsKey('data') ? response['data'] : response;
      ticket = Ticket.fromJson(updatedData as Map<String, dynamic>);
    } catch (e) {
      _errorMessage = 'Failed to claim ticket: ${e.toString().replaceAll('Exception: ', '')}';
    } finally {
      _isClaiming = false;
      _evaluateTimer(); 
      notifyListeners();
    }
  }

  Future<bool> syncTicketTags(List<int> selectedTagIds) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      ticket = await ticketRepository.syncTags(ticket.id, selectedTagIds);
      return true;
    } catch (e) {
      _errorMessage = 'Failed to sync tags: ${e.toString().replaceAll('Exception: ', '')}';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void _evaluateTimer() {
    final bool shouldRun = isStaff && hasWritePermission && ticket.status == 'in_progress';
    if (shouldRun && _supportTimer == null) {
      _tickTime();
      _supportTimer = Timer.periodic(const Duration(seconds: 5), (_) => _tickTime());
    } else if (!shouldRun && _supportTimer != null) {
      _supportTimer?.cancel();
      _supportTimer = null;
    }
  }

  Future<void> _tickTime() async {
    try {
      final response = await ticketRepository.tickTime(ticket.id, {});
      final data = response.containsKey('data') ? response['data'] : response;
      if (data != null && data['remaining_seconds'] != null) {
        ticket = ticket.copyWith(supportTime: _formatSeconds(data['remaining_seconds'] as int));
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Support timer tick failed: $e');
    }
  }

  String _formatSeconds(int totalSeconds) {
    if (totalSeconds < 0) totalSeconds = 0;
    final hours = totalSeconds ~/ 3600;
    final minutes = (totalSeconds % 3600) ~/ 60;
    final seconds = totalSeconds % 60;
    return '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }
}