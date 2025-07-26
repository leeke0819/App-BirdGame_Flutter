import 'package:flame/cache.dart';
import 'package:flame/game.dart';
import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/input.dart';
import 'package:flame/collisions.dart';
import 'package:flame/text.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:math';

class JumpGame extends FlameGame with TapDetector, HasCollisionDetection {
  late Player player;
  late TextComponent scoreText;
  late TextComponent countdownText;
  late ScrollingBackground scrollingBackground;
  int score = 0;
  bool gameStarted = true;
  bool gameOver = false;
  bool obstaclesEnabled = false;
  double obstacleSpeed = 100;
  double timeSinceLastObstacle = 0;
  final double obstacleSpawnInterval = 2.0;
  final Random random = Random();
  final void Function()? onGameOver;
  final void Function()? onExitGame;
  final void Function()? onRestart;
  TextComponent? gameOverText;

  JumpGame({this.onGameOver, this.onExitGame, this.onRestart});
  final images = Images(prefix: '');

  @override
  Future<void> onLoad() async {
    print('JumpGame onLoad');
    try {
      print('이미지 프리로드 시작...');
      await images.loadAll([
        'images/birds/PNG/Omoknoonii/fly_bird1.png',
        'images/birds/PNG/Omoknoonii/fly_bird2.png',
        'images/birds/PNG/Omoknoonii/fly_bird3.png',
        'images/birds/PNG/Omoknoonii/fly_bird4.png',
        'images/birds/PNG/Omoknoonii/fly_bird5.png',
      ]);
      print('이미지 프리로드 성공');
    } catch (e) {
      print('이미지 프리로드 실패: $e');
      // 개별 이미지 로딩 시도
      for (int i = 1; i <= 5; i++) {
        try {
          await images.load('images/birds/PNG/Omoknoonii/fly_bird$i.png');
          print('개별 이미지 $i 로딩 성공');
        } catch (e) {
          print('개별 이미지 $i 로딩 실패: $e');
        }
      }
    }

    // 스크롤링 배경 설정
    scrollingBackground = ScrollingBackground();
    add(scrollingBackground);

    // 플레이어 생성
    player = Player();
    player.position = Vector2(100, size.y / 2); // 초기 위치 설정
    add(player);

    // 점수 텍스트
    scoreText = TextComponent(
      text: 'Score: 0',
      position: Vector2(10, 10),
      textRenderer: TextPaint(
        style: const TextStyle(
          fontSize: 24,
          color: Colors.black,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
    add(scoreText);

    // 카운트다운 텍스트
    countdownText = TextComponent(
      text: '3',
      position: Vector2(size.x / 2, size.y / 2),
      anchor: Anchor.center,
      textRenderer: TextPaint(
        style: const TextStyle(
          fontSize: 72,
          color: Colors.black,
          fontWeight: FontWeight.bold,
          shadows: [
            Shadow(
              offset: Offset(2, 2),
              blurRadius: 4,
              color: Colors.white,
            ),
          ],
        ),
      ),
    );
    add(countdownText);

    // 3초 카운트다운 후 장애물 활성화
    _startCountdown();
  }

  Future<void> _startCountdown() async {
    for (int i = 3; i > 0; i--) {
      countdownText.text = i.toString();
      await Future.delayed(const Duration(seconds: 1));
    }
    countdownText.text = 'GO!';
    await Future.delayed(const Duration(milliseconds: 500));
    countdownText.removeFromParent();
    obstaclesEnabled = true;
  }

  @override
  void update(double dt) {
    super.update(dt);

    if (!gameStarted || gameOver) return;

    // 점수 업데이트
    score++;
    scoreText.text = 'Score: $score';

    // 장애물이 활성화된 후에만 생성
    if (obstaclesEnabled) {
      timeSinceLastObstacle += dt;
      if (timeSinceLastObstacle >= obstacleSpawnInterval) {
        _spawnObstacle();
        timeSinceLastObstacle = 0;
      }

      // 게임 속도 증가
      obstacleSpeed += dt * 10;
    }
  }

  void _spawnObstacle() {
    final gapHeight = 300.0; // 기둥 위아래 간격
    final minGapPosition = 100.0; // 최소 간격 위치
    final maxGapPosition = size.y - gapHeight - 100.0; // 최대 간격 위치
    
    // 간격 위치를 더 안전한 범위로 제한
    final gapPosition = random.nextDouble() * (maxGapPosition - minGapPosition) + minGapPosition;

    // 위쪽 기둥 - 위쪽 끝까지 확실히 연결
    final topObstacleHeight = gapPosition;
    final topObstacle = Obstacle(
      position: Vector2(size.x, 0), // 위쪽 끝(0)에서 시작
      size: Vector2(50, topObstacleHeight),
      isTop: true,
    );
    add(topObstacle);

    // 아래쪽 기둥 - 아래쪽 끝까지 확실히 연결
    final bottomObstacleY = gapPosition + gapHeight;
    final bottomObstacleHeight = size.y - bottomObstacleY;
    final bottomObstacle = Obstacle(
      position: Vector2(size.x, bottomObstacleY),
      size: Vector2(50, bottomObstacleHeight),
      isTop: false,
    );
    add(bottomObstacle);
  }






  @override
  void onTap() {
    if (gameStarted && !gameOver) {
      player.jump();
    } else if (gameOver) {
      // 게임오버 상태에서 탭하면 재시작
      restart();
    }
  }

  void endGame() {
    // 이미 게임오버 상태라면 중복 호출 방지
    if (gameOver) return;
    
    gameOver = true;

    // 기존 Game Over 텍스트 제거
    gameOverText?.removeFromParent();

    // 새 Game Over 텍스트 생성
    gameOverText = TextComponent(
      text: 'Game Over!\nScore: $score',
      position: Vector2(size.x / 2, size.y / 2 - 50), // 위로 올림
      anchor: Anchor.center,
      textRenderer: TextPaint(
        style: const TextStyle(
          fontSize: 32,
          color: Colors.red,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
    if (gameOverText != null) {
      add(gameOverText!);
    }

    // 게임오버 오버레이 표시
    overlays.add('game_over');

    onGameOver?.call();
  }

  void restart() {
    // 게임 상태 초기화
    score = 0;
    gameOver = false;
    obstaclesEnabled = false;
    obstacleSpeed = 100;
    timeSinceLastObstacle = 0;

    // 모든 장애물 제거
    children
        .whereType<Obstacle>()
        .forEach((obstacle) => obstacle.removeFromParent());

    // 플레이어 위치 초기화
    player.position = Vector2(100, size.y / 2);
    player.velocity = Vector2.zero();
    player.hasCollided = false; // 충돌 상태 초기화
    
    // 플레이어 충돌 박스 다시 추가
    player.add(RectangleHitbox());

    // Game Over 텍스트 제거
    gameOverText?.removeFromParent();
    gameOverText = null;

    // 게임오버 오버레이 제거
    overlays.remove('game_over');

    // 점수 텍스트 초기화
    scoreText.text = 'Score: 0';

    // 카운트다운 다시 시작
    _startCountdown();
    
    // 재시작 콜백 호출
    onRestart?.call();
  }
}

class Player extends SpriteAnimationComponent with CollisionCallbacks {
  Vector2 velocity = Vector2.zero();
  final double gravity = 800;
  final double jumpForce = -600;
  bool isJumping = false;
  bool hasCollided = false; // 충돌 감지 상태 추가
  late JumpGame jumpGame;

  Player() : super(size: Vector2(72, 69));

  @override
  Future<void> onLoad() async {
    // 게임 참조 저장
    jumpGame = parent as JumpGame;

    try {
      // 먼저 하나의 이미지만 로드해서 테스트
      print('이미지 로딩 시작...');
      
      final testSprite = await Sprite.load(
        'images/birds/PNG/Omoknoonii/fly_bird1.png',
        images: jumpGame.images,
      );
      print('테스트 이미지 로딩 성공');
      
      // 성공하면 나머지 이미지들도 로드
      final sprites = <Sprite>[testSprite];
      
      for (int i = 2; i <= 5; i++) {
        try {
          final sprite = await Sprite.load(
            'images/birds/PNG/Omoknoonii/fly_bird$i.png',
            images: jumpGame.images,
          );
          sprites.add(sprite);
          print('이미지 $i 로딩 성공');
        } catch (e) {
          print('이미지 $i 로딩 실패: $e');
          // 실패한 이미지는 첫 번째 이미지로 대체
          sprites.add(testSprite);
        }
      }

      // 애니메이션 생성 (0.1초마다 프레임 변경)
      animation = SpriteAnimation.spriteList(
        sprites,
        stepTime: 0.1,
      );
      print('애니메이션 생성 성공: ${sprites.length}개 프레임');
      
      // 이미지 크기 정보 출력
      print('Player 크기: ${size.x} x ${size.y}');
      
    } catch (e) {
      print('이미지 로딩 오류: $e');
      // 이미지 로딩 실패 시 기본 사각형으로 대체
      paint = Paint()..color = Colors.blue;
    }

    // 충돌 박스 추가 (사각형으로 충돌 감지)
    add(RectangleHitbox());
  }

  void jump() {
    // 점프 중이어도 재점프 가능하도록 수정
    velocity.y = jumpForce;
    isJumping = true;
  }

  @override
  void update(double dt) {
    super.update(dt);

    // 중력 적용
    velocity.y += gravity * dt;
    position += velocity * dt;

    // 바닥 체크 - 바닥에 닿으면 게임오버
    if (position.y > jumpGame.size.y - size.y) {
      // 이미 충돌했거나 게임이 끝났으면 무시
      if (!hasCollided && !jumpGame.gameOver) {
        hasCollided = true;
        // 충돌 감지 완전 비활성화 - 모든 충돌 박스 제거
        removeAll(children.whereType<RectangleHitbox>());
        jumpGame.endGame();
      }
      return;
    }

    // 천장 체크
    if (position.y < 0) {
      position.y = 0;
      velocity.y = 0;
    }
  }

  @override
  void onCollision(Set<Vector2> intersectionPoints, PositionComponent other) {
    // 이미 충돌했거나 게임이 끝났으면 무시
    if (hasCollided || jumpGame.gameOver) return;
    
    if (other is Obstacle) {
      // 충돌 상태 설정
      hasCollided = true;
      
      // 충돌 감지 완전 비활성화 - 모든 충돌 박스 제거
      removeAll(children.whereType<RectangleHitbox>());
      
      // 게임 종료
      jumpGame.endGame();
      
      return;
    }
  }
}

class Obstacle extends RectangleComponent with CollisionCallbacks {
  final bool isTop;
  final double speed = 200;

  Obstacle({
    required Vector2 position,
    required Vector2 size,
    required this.isTop,
  }) : super(position: position, size: size);

  @override
  Future<void> onLoad() async {
    // 장애물 색상 (위쪽은 빨간색, 아래쪽은 초록색)
    paint = Paint()..color = isTop ? Colors.red : Colors.green;

    // 충돌 박스 추가
    add(RectangleHitbox());
  }

  @override
  void update(double dt) {
    super.update(dt);

    // 왼쪽으로 이동
    position.x -= speed * dt;

    // 화면 밖으로 나가면 제거
    if (position.x < -size.x) {
      removeFromParent();
    }
  }
}

class JumpGameWidget extends StatefulWidget {
  const JumpGameWidget({super.key, required this.onGameOver, this.onExitGame, this.onRestart});
  final VoidCallback onGameOver;
  final VoidCallback? onExitGame;
  final VoidCallback? onRestart;

  @override
  State<JumpGameWidget> createState() => _JumpGameWidgetState();
}

class _JumpGameWidgetState extends State<JumpGameWidget> {
  late JumpGame _game;

  @override
  void initState() {
    super.initState();
    _game = JumpGame(
      onGameOver: widget.onGameOver,
      onExitGame: widget.onExitGame,
      onRestart: widget.onRestart,
    );
  }

  @override
  Widget build(BuildContext context) {
    return GameWidget(
      game: _game,
      overlayBuilderMap: {
        'pause_menu': (context, game) => const PauseMenu(),
        'game_over': (context, game) => GameOverOverlay(game: game as JumpGame),
      },
    );
  }
}

class ScrollingBackground extends PositionComponent {
  late Sprite backgroundSprite;
  late SpriteComponent background1;
  late SpriteComponent background2;
  final double scrollSpeed = 50.0; // 배경 스크롤 속도
  late JumpGame jumpGame;

  @override
  Future<void> onLoad() async {
    // 게임 참조 저장
    jumpGame = parent as JumpGame;
    
    try {
      // 배경 이미지 로드 (기본 하늘색으로 대체)
      backgroundSprite = await Sprite.load('images/background/game1_background.png', images: jumpGame.images);
    } catch (e) {
      print('배경 이미지 로딩 실패: $e');
      // 이미지 로딩 실패 시 기본 색상 사용
      return;
    }

    // 첫 번째 배경
    background1 = SpriteComponent(
      sprite: backgroundSprite,
      size: jumpGame.size,
      position: Vector2.zero(),
    );
    add(background1);

    // 두 번째 배경 (첫 번째 배경과 약간 겹치게 배치하여 간격 제거)
    background2 = SpriteComponent(
      sprite: backgroundSprite,
      size: jumpGame.size,
      position: Vector2(jumpGame.size.x - 2, 0), // 2픽셀 겹치게 배치
    );
    add(background2);
  }

  @override
  void update(double dt) {
    super.update(dt);

    // 배경을 왼쪽으로 이동
    background1.position.x -= scrollSpeed * dt;
    background2.position.x -= scrollSpeed * dt;

    // 첫 번째 배경이 화면 밖으로 나가면 오른쪽으로 이동
    if (background1.position.x <= -jumpGame.size.x) {
      background1.position.x = background2.position.x + jumpGame.size.x - 2; // 2픽셀 겹치게
    }

    // 두 번째 배경이 화면 밖으로 나가면 오른쪽으로 이동
    if (background2.position.x <= -jumpGame.size.x) {
      background2.position.x = background1.position.x + jumpGame.size.x - 2; // 2픽셀 겹치게
    }
  }
}

class PauseMenu extends StatelessWidget {
  const PauseMenu({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black54,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              '일시정지',
              style: TextStyle(
                fontSize: 32,
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                // 게임 재개
              },
              child: const Text('계속하기'),
            ),
          ],
        ),
      ),
    );
  }
}

class GameOverOverlay extends StatelessWidget {
  final JumpGame game;

  const GameOverOverlay({super.key, required this.game});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(height: 80), // 텍스트와 버튼 사이 간격 늘림
          ElevatedButton(
            onPressed: () {
              game.restart();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: const Text(
              '재시작',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(height: 15), // 버튼 사이 간격
          ElevatedButton(
            onPressed: () {
              game.onExitGame?.call();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: const Text(
              '게임 종료',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
