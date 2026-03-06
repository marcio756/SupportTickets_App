import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:supporttickets_app/features/work_sessions/models/work_session.dart';
import 'package:supporttickets_app/features/work_sessions/repositories/work_session_repository.dart';

/// Manages the state of the user's work session and synchronizes the local timer.
class WorkSessionViewModel extends ChangeNotifier {
  final WorkSessionRepository _repository;

  WorkSession? _currentSession;
  bool _isLoading = false;
  String? _errorMessage;
  int _currentDurationSeconds = 0;
  Timer? _timer;

  WorkSessionViewModel({required WorkSessionRepository repository}) : _repository = repository;

  WorkSession? get currentSession => _currentSession;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  int get currentDurationSeconds => _currentDurationSeconds;
  
  bool get isActive => _currentSession != null && _currentSession!.status == 'active';
  bool get isPaused => _currentSession != null && _currentSession!.status == 'paused';
  bool get isCompleted => _currentSession != null && _currentSession!.status == 'completed';

  @visibleForTesting
  set currentSession(WorkSession? session) {
    _currentSession = session;
    if (session != null) _currentDurationSeconds = session.totalDurationSeconds;
  }

  Future<void> loadCurrentSession() async {
    _setLoading(true);
    try {
      final session = await _repository.getCurrentSession();
      _handleSessionUpdate(session);
    } catch (e) {
      _setError(e.toString());
    } finally {
      _setLoading(false);
    }
  }

  Future<void> startSession() async {
    _setLoading(true);
    try {
      final session = await _repository.startSession();
      _handleSessionUpdate(session);
    } catch (e) {
      _setError(e.toString());
    } finally {
      _setLoading(false);
    }
  }

  Future<void> pauseSession() async {
    _setLoading(true);
    try {
      final session = await _repository.pauseSession();
      _handleSessionUpdate(session);
    } catch (e) {
      _setError(e.toString());
    } finally {
      _setLoading(false);
    }
  }

  Future<void> resumeSession() async {
    _setLoading(true);
    try {
      final session = await _repository.resumeSession();
      _handleSessionUpdate(session);
    } catch (e) {
      _setError(e.toString());
    } finally {
      _setLoading(false);
    }
  }

  Future<void> endSession() async {
    _setLoading(true);
    try {
      final session = await _repository.endSession();
      _handleSessionUpdate(session);
    } catch (e) {
      _setError(e.toString());
    } finally {
      _setLoading(false);
    }
  }

  void _handleSessionUpdate(WorkSession? session) {
    _currentSession = session;
    _errorMessage = null;

    if (session != null) {
      // Architecture Guard: Prevent backend from zeroing out the timer on pause/resume
      if (session.totalDurationSeconds > _currentDurationSeconds || _currentDurationSeconds == 0) {
        _currentDurationSeconds = session.totalDurationSeconds;
      }
      
      if (session.status == 'active') {
        _startTimer();
      } else {
        _stopTimer();
      }
    } else {
      _currentDurationSeconds = 0;
      _stopTimer();
    }
    
    notifyListeners();
  }

  void _startTimer() {
    _stopTimer(); 
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      _currentDurationSeconds++;
      notifyListeners();
    });
  }

  void _stopTimer() {
    _timer?.cancel();
    _timer = null;
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void _setError(String message) {
    _errorMessage = message;
    notifyListeners();
  }

  @override
  void dispose() {
    _stopTimer();
    super.dispose();
  }
}