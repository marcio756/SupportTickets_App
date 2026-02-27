import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:file_picker/file_picker.dart';
import '../models/ticket.dart';
import '../models/ticket_message.dart';
import '../repositories/ticket_repository.dart';
import '../../profile/repositories/profile_repository.dart';

/// ViewModel responsible for managing the state and logic of a specific ticket's details.
class TicketDetailsViewModel extends ChangeNotifier {
  final TicketRepository ticketRepository;
  final ProfileRepository profileRepository;
  
  Ticket ticket;

  List<TicketMessage> _messages = [];
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
  bool get isLoading => _isLoading;
  bool get isSending => _isSending;
  bool get isUpdatingStatus => _isUpdatingStatus;
  bool get isClaiming => _isClaiming;
  String? get errorMessage => _errorMessage;
  int? get currentUserId => _currentUserId;
  
  bool get isSupporter => _currentUserRole == 'supporter';

  @override
  void dispose() {
    // Critical: Clean up the timer when the screen is closed to prevent background API spam
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
        if (profileData['id'] != null) {
          _currentUserId = int.tryParse(profileData['id'].toString());
        }
        if (profileData['role'] != null) {
          _currentUserRole = profileData['role'].toString();
        }
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

  Future<bool> sendMessage(String? messageText, {PlatformFile? attachment}) async {
    if ((messageText == null || messageText.trim().isEmpty) && attachment == null) return false;

    _isSending = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final newMessage = await ticketRepository.sendMessage(
        ticket.id, 
        messageText, 
        userId: _currentUserId,
        attachment: attachment,
      );
      
      _messages.add(newMessage);
      _isSending = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = 'Failed to send message: ${e.toString().replaceAll('Exception: ', '')}';
      _isSending = false;
      notifyListeners();
      return false;
    }
  }

  Future<void> updateStatus(String newStatus) async {
    _isUpdatingStatus = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final updatedTicket = await ticketRepository.updateTicketStatus(ticket.id, newStatus);
      ticket = updatedTicket;
    } catch (e) {
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
      _errorMessage = 'Falha ao reivindicar: ${e.toString().replaceAll('Exception: ', '')}';
    } finally {
      _isClaiming = false;
      _evaluateTimer(); 
      notifyListeners();
    }
  }

  /// Evaluates whether the background support timer should be running.
  void _evaluateTimer() {
    final bool shouldRun = isSupporter &&
        ticket.status == 'in_progress' &&
        ticket.assigneeId == _currentUserId;

    if (shouldRun && _supportTimer == null) {
      // Fires immediately to show the timer instantly on screen, then triggers every 5 secs
      _tickTime();
      _supportTimer = Timer.periodic(const Duration(seconds: 5), (_) => _tickTime());
    } else if (!shouldRun && _supportTimer != null) {
      _supportTimer?.cancel();
      _supportTimer = null;
    }
  }

  /// Sends the background tick to the API and updates local UI.
  Future<void> _tickTime() async {
    try {
      final response = await ticketRepository.tickTime(ticket.id, {});
      final data = response.containsKey('data') ? response['data'] : response;

      if (data != null && data['remaining_seconds'] != null) {
        final int seconds = data['remaining_seconds'] as int;
        final formattedTime = _formatSeconds(seconds);

        ticket = ticket.copyWith(supportTime: formattedTime);
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Support timer tick failed: $e');
    }
  }

  /// Helper to convert raw seconds back to HH:MM:SS format
  String _formatSeconds(int totalSeconds) {
    if (totalSeconds < 0) totalSeconds = 0;
    final hours = totalSeconds ~/ 3600;
    final minutes = (totalSeconds % 3600) ~/ 60;
    final seconds = totalSeconds % 60;
    
    return '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }
}