import 'dart:async';
import 'package:flutter/foundation.dart';

class TimerService {
  static final TimerService _instance = TimerService._internal();
  factory TimerService() => _instance;
  TimerService._internal();

  DateTime? _startTime;
  Timer? _timer;
  Duration _elapsedTime = Duration.zero;
  final List<Function(Duration)> _listeners = [];

  /// 앱 시작 시간을 설정하고 타이머를 시작합니다.
  void startTimer() {
    if (_startTime == null) {
      _startTime = DateTime.now();
      _startPeriodicTimer();
      if (kDebugMode) {
        print('TimerService: 타이머가 시작되었습니다. 시작 시간: $_startTime');
      }
    }
  }

  /// 주기적으로 경과 시간을 업데이트하는 타이머를 시작합니다.
  void _startPeriodicTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_startTime != null) {
        _elapsedTime = DateTime.now().difference(_startTime!);
        _notifyListeners();
      }
    });
  }

  /// 경과 시간을 반환합니다.
  Duration get elapsedTime => _elapsedTime;

  /// 경과 시간을 포맷된 문자열로 반환합니다.
  String get formattedElapsedTime {
    final hours = _elapsedTime.inHours;
    final minutes = _elapsedTime.inMinutes.remainder(60);
    final seconds = _elapsedTime.inSeconds.remainder(60);
    
    if (hours > 0) {
      return '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
    } else {
      return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
    }
  }

  /// 경과 시간을 한국어 형식으로 반환합니다.
  String get koreanFormattedTime {
    final hours = _elapsedTime.inHours;
    final minutes = _elapsedTime.inMinutes.remainder(60);
    final seconds = _elapsedTime.inSeconds.remainder(60);
    
    if (hours > 0) {
      return '${hours}시간 ${minutes}분 ${seconds}초';
    } else if (minutes > 0) {
      return '${minutes}분 ${seconds}초';
    } else {
      return '${seconds}초';
    }
  }

  /// 리스너를 추가합니다.
  void addListener(Function(Duration) listener) {
    _listeners.add(listener);
  }

  /// 리스너를 제거합니다.
  void removeListener(Function(Duration) listener) {
    _listeners.remove(listener);
  }

  /// 모든 리스너에게 경과 시간을 알립니다.
  void _notifyListeners() {
    for (final listener in _listeners) {
      listener(_elapsedTime);
    }
  }

  /// 타이머를 일시정지합니다.
  void pauseTimer() {
    _timer?.cancel();
    if (kDebugMode) {
      print('TimerService: 타이머가 일시정지되었습니다.');
    }
  }

  /// 타이머를 재시작합니다.
  void resumeTimer() {
    if (_startTime != null) {
      _startPeriodicTimer();
      if (kDebugMode) {
        print('TimerService: 타이머가 재시작되었습니다.');
      }
    }
  }

  /// 타이머를 리셋합니다.
  void resetTimer() {
    _timer?.cancel();
    _startTime = DateTime.now();
    _elapsedTime = Duration.zero;
    _startPeriodicTimer();
    _notifyListeners();
    if (kDebugMode) {
      print('TimerService: 타이머가 리셋되었습니다.');
    }
  }

  /// 타이머를 완전히 중지하고 정리합니다.
  void dispose() {
    _timer?.cancel();
    _listeners.clear();
    if (kDebugMode) {
      print('TimerService: 타이머가 정리되었습니다.');
    }
  }

  /// 앱 시작 시간을 반환합니다.
  DateTime? get startTime => _startTime;

  /// 타이머가 실행 중인지 확인합니다.
  bool get isRunning => _timer?.isActive ?? false;
}
