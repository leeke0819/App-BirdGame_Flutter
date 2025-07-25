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
  int score = 0;
  bool gameStarted = true;
  bool gameOver = false;
  bool obstaclesEnabled = false;
  double obstacleSpeed = 100;
  double timeSinceLastObstacle = 0;
  final double obstacleSpawnInterval = 2.0;
  final Random random = Random();
  final void Function()? onGameOver;

  JumpGame({this.onGameOver});

  @override
  Future<void> onLoad() async {
    // 배경 설정 - 더 밝은 색상으로 변경
    add(
      RectangleComponent(
        size: size,
        paint: Paint()..color = const Color(0xFF87CEEB), // 하늘색 배경
      ),
    );

    // 플레이어 생성
    player = Player();
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
    final gapHeight = 150.0;
    final gapPosition = random.nextDouble() * (size.y - gapHeight - 100) + 50;

    // 위쪽 기둥
    final topObstacle = Obstacle(
      position: Vector2(size.x, gapPosition - 200),
      size: Vector2(50, 200),
      isTop: true,
    );
    add(topObstacle);

    // 아래쪽 기둥
    final bottomObstacle = Obstacle(
      position: Vector2(size.x, gapPosition + gapHeight),
      size: Vector2(50, size.y - gapPosition - gapHeight),
      isTop: false,
    );
    add(bottomObstacle);
  }

  @override
  void onTap() {
    if (gameStarted && !gameOver) {
      player.jump();
    }
  }

  void endGame() {
    gameOver = true;

    // 게임오버 텍스트
    final gameOverText = TextComponent(
      text: 'Game Over!\nScore: $score\nTap to restart',
      position: Vector2(size.x / 2, size.y / 2),
      anchor: Anchor.center,
      textRenderer: TextPaint(
        style: const TextStyle(
          fontSize: 32,
          color: Colors.red,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
    add(gameOverText);
    if (onGameOver != null) {
      onGameOver!();
    }
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

    // 게임오버 텍스트 제거
    children.whereType<TextComponent>().forEach((text) {
      if (text.text.contains('Game Over')) {
        text.removeFromParent();
      }
    });

    // 점수 텍스트 초기화
    scoreText.text = 'Score: 0';

    // 카운트다운 다시 시작
    _startCountdown();
  }
}

class Player extends SpriteAnimationComponent with CollisionCallbacks {
  Vector2 velocity = Vector2.zero();
  final double gravity = 800;
  final double jumpForce = -600;
  bool isJumping = false;
  late JumpGame jumpGame;

  Player() : super(size: Vector2(60, 60));

  @override
  Future<void> onLoad() async {
    // 게임 참조 저장
    jumpGame = parent as JumpGame;

    // 5개의 새 이미지를 로드하여 애니메이션 생성
    final sprites = [
      await Sprite.load('images/birds/PNG/Omoknoonii/fly_bird1.png',
          images: jumpGame.images),
      await Sprite.load('images/birds/PNG/Omoknoonii/fly_bird2.png',
          images: jumpGame.images),
      await Sprite.load('images/birds/PNG/Omoknoonii/fly_bird3.png',
          images: jumpGame.images),
      await Sprite.load('images/birds/PNG/Omoknoonii/fly_bird4.png',
          images: jumpGame.images),
      await Sprite.load('images/birds/PNG/Omoknoonii/fly_bird5.png',
          images: jumpGame.images),
    ];

    // 애니메이션 생성 (0.1초마다 프레임 변경)
    animation = SpriteAnimation.spriteList(
      sprites,
      stepTime: 0.1,
    );

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

    // 바닥 체크
    if (position.y > jumpGame.size.y - size.y) {
      position.y = jumpGame.size.y - size.y;
      velocity.y = 0;
      isJumping = false;
    }

    // 천장 체크
    if (position.y < 0) {
      position.y = 0;
      velocity.y = 0;
    }
  }

  @override
  void onCollision(Set<Vector2> intersectionPoints, PositionComponent other) {
    if (other is Obstacle) {
      jumpGame.endGame();
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
  const JumpGameWidget({super.key, required this.onGameOver});
  final VoidCallback onGameOver;

  @override
  State<JumpGameWidget> createState() => _JumpGameWidgetState();
}

class _JumpGameWidgetState extends State<JumpGameWidget> {
  late JumpGame _game;

  @override
  void initState() {
    super.initState();
    _game = JumpGame(onGameOver: widget.onGameOver);
  }

  @override
  Widget build(BuildContext context) {
    return GameWidget(
      game: _game,
      overlayBuilderMap: {
        'pause_menu': (context, game) => const PauseMenu(),
      },
    );
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
