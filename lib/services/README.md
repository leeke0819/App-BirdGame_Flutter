# TimerService

앱이 시작된 후부터 경과 시간을 추적하는 싱글톤 타이머 서비스입니다.

## 기능

- 앱 시작 시간부터 경과 시간 추적
- 실시간 타이머 업데이트 (1초마다)
- 다양한 시간 형식 지원 (HH:MM:SS, 한국어 형식)
- 타이머 제어 (시작, 일시정지, 재시작, 리셋)
- 리스너 패턴을 통한 UI 업데이트

## 사용법

### 1. 앱 시작 시 타이머 초기화

```dart
// main.dart
import 'package:bird_raise_app/services/timer_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // 전역 타이머 서비스 시작
  TimerService().startTimer();
  
  // ... 나머지 앱 초기화 코드
}
```

### 2. 위젯에서 타이머 사용

```dart
import 'package:bird_raise_app/services/timer_service.dart';

class MyWidget extends StatefulWidget {
  @override
  _MyWidgetState createState() => _MyWidgetState();
}

class _MyWidgetState extends State<MyWidget> {
  final TimerService _timerService = TimerService();
  String _elapsedTime = '00:00';

  @override
  void initState() {
    super.initState();
    // 타이머 업데이트 리스너 추가
    _timerService.addListener(_onTimerUpdate);
  }

  void _onTimerUpdate(Duration elapsedTime) {
    if (mounted) {
      setState(() {
        _elapsedTime = _timerService.formattedElapsedTime;
      });
    }
  }

  @override
  void dispose() {
    // 리스너 제거
    _timerService.removeListener(_onTimerUpdate);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Text('경과 시간: $_elapsedTime');
  }
}
```

## API 참조

### 속성

- `elapsedTime`: 현재 경과 시간 (Duration)
- `formattedElapsedTime`: 포맷된 경과 시간 문자열 (HH:MM:SS)
- `koreanFormattedTime`: 한국어 형식 경과 시간 (예: "1시간 30분 45초")
- `startTime`: 앱 시작 시간 (DateTime?)
- `isRunning`: 타이머 실행 상태 (bool)

### 메서드

#### 타이머 제어

- `startTimer()`: 타이머 시작 (앱 시작 시 한 번만 호출)
- `pauseTimer()`: 타이머 일시정지
- `resumeTimer()`: 타이머 재시작
- `resetTimer()`: 타이머 리셋
- `dispose()`: 타이머 정리

#### 리스너 관리

- `addListener(Function(Duration) listener)`: 리스너 추가
- `removeListener(Function(Duration) listener)`: 리스너 제거

## 예시

```dart
// 타이머 인스턴스 생성
final timerService = TimerService();

// 경과 시간 가져오기
Duration elapsed = timerService.elapsedTime;
String formatted = timerService.formattedElapsedTime; // "01:30:45"
String korean = timerService.koreanFormattedTime; // "1시간 30분 45초"

// 타이머 제어
timerService.pauseTimer(); // 일시정지
timerService.resumeTimer(); // 재시작
timerService.resetTimer(); // 리셋
```

## 주의사항

1. `startTimer()`는 앱 시작 시 한 번만 호출해야 합니다.
2. 위젯에서 타이머를 사용할 때는 반드시 `dispose()`에서 리스너를 제거해야 합니다.
3. 타이머는 싱글톤 패턴으로 구현되어 앱 전체에서 하나의 인스턴스만 존재합니다.
4. 메모리 누수를 방지하기 위해 위젯이 dispose될 때 리스너를 제거하는 것을 잊지 마세요.

## 예시 파일

`timer_service_example.dart` 파일에서 TimerService의 전체 사용법을 확인할 수 있습니다. 