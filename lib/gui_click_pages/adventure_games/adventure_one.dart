import 'package:bird_raise_app/api/api_game.dart';
import 'package:bird_raise_app/api/user.dart';
import 'package:bird_raise_app/model/gold_model.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:bird_raise_app/main_page.dart';
import 'package:bird_raise_app/gui_click_pages/adventure_games/adv_jump.dart';
import 'package:provider/provider.dart';

class AdventureOne extends StatefulWidget {
  const AdventureOne({super.key});

  @override
  State<AdventureOne> createState() => _AdventureOneState();
}

class _AdventureOneState extends State<AdventureOne>
    with WidgetsBindingObserver {
  bool gameStarted = false;
  bool gameOver = false;
  String? sessionId;
  bool isGameOverRequested = false; // ✅ 중복 호출 방지용
  bool isResultDialogShown = false; // 결과 팝업 표시 여부

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    print('🔄 앱 생명주기 변경: $state');

    // 앱이 포그라운드로 돌아올 때 포커스 강제 활성화
    if (state == AppLifecycleState.resumed) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          FocusScope.of(context).requestFocus(FocusNode());
          print('✅ 앱 복귀 시 포커스 활성화됨');
        }
      });
    }
  }

  void _handleGameOver() async {
    if (isGameOverRequested) return; // ✅ 중복 호출 방지
    isGameOverRequested = true;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      setState(() {
        gameOver = true;
      });
    });

    if (sessionId != null) {
      final result = await ApiGame.gameOver(sessionId!);
      print('✅ 서버 응답: $result');

      // ✅ 골드 최신값 가져오기 + UI 반영
      int? latestGold = await fetchUserGold(); // gold만 가져올 경우
      if (latestGold != null) {
        context.read<GoldModel>().updateGold(latestGold);
      }

      // ✅ 결과 팝업 표시 (보상 등) - 중복 방지
      if (result != null && !isResultDialogShown) {
        isResultDialogShown = true;
        final int reward = result['reward'];
        final int duration = result['duration'];

        showDialog(
          context: context,
          builder: (_) => AlertDialog(
            title: const Text('🎉 게임 결과'),
            content: Text('생존 시간: $duration초\n획득 골드: $reward G'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('확인'),
              ),
            ],
          ),
        );
      }
    } else {
      print('❌ sessionId가 null입니다');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Get.back(),
        ),
        title: const Text(
          '비행 연습',
          style: TextStyle(
            fontFamily: 'NaverNanumSquareRound',
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: gameStarted
          ? JumpGameWidget(
              onGameOver: _handleGameOver,
              onExitGame: () {
                isGameOverRequested = false; // 초기화
                isResultDialogShown = false; // 결과 팝업 표시 여부 초기화
                Get.back();
              },
              onRestart: () async {
                isGameOverRequested = false; // 재시작 시 초기화
                isResultDialogShown = false; // 결과 팝업 표시 여부 초기화
                // 새로운 세션 시작
                sessionId = await ApiGame.startGame(1);
                if (sessionId == null) {
                  print('❌ 재시작 시 게임 시작 실패');
                }
              },
            )
          : Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.blue[100]!,
                    Colors.blue[200]!,
                  ],
                ),
              ),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // 게임 제목
                    const Text(
                      '비행 연습',
                      style: TextStyle(
                        fontSize: 48,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        fontFamily: 'NaverNanumSquareRound',
                        shadows: [
                          Shadow(
                            offset: Offset(2, 2),
                            blurRadius: 4,
                            color: Colors.black,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 40),
                    // 게임 설명
                    Container(
                      margin: const EdgeInsets.symmetric(horizontal: 40),
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.9),
                        borderRadius: BorderRadius.circular(15),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.2),
                            blurRadius: 10,
                            offset: const Offset(0, 5),
                          ),
                        ],
                      ),
                      child: const Column(
                        children: [
                          Text(
                            '게임 방법',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                              fontFamily: 'NaverNanumSquareRound',
                            ),
                          ),
                          SizedBox(height: 15),
                          Text(
                            '• 화면을 탭하여 날아오르세요\n'
                            '• 장애물을 피해 최대한 오래 생존하세요\n'
                            '• 생존 시간에 따라 골드를 획득할 수 있습니다',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.black87,
                              fontFamily: 'NaverNanumSquareRound',
                              height: 1.5,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 50),
                    // 게임 시작 버튼
                    InkWell(
                      onTap: () async {
                        print('🎮 게임 시작 버튼 터치됨');

                        // 포커스 확인 및 강제 활성화
                        if (!mounted) {
                          print('❌ 위젯이 마운트되지 않음');
                          return;
                        }

                        // 현재 컨텍스트가 활성 상태인지 확인
                        final currentContext = context;
                        if (currentContext.mounted) {
                          // 포커스 강제 활성화
                          FocusScope.of(currentContext)
                              .requestFocus(FocusNode());
                          print('✅ 포커스 활성화됨');
                        }

                        // 앱이 포그라운드에 있는지 확인
                        final appState = WidgetsBinding.instance.lifecycleState;
                        print('📱 현재 앱 상태: $appState');

                        // 포커스 강제 활성화 (여러 방법 시도)
                        try {
                          FocusScope.of(context).requestFocus(FocusNode());
                          FocusManager.instance.primaryFocus?.unfocus();
                          FocusManager.instance.primaryFocus?.requestFocus();
                          print('✅ 포커스 강제 활성화 완료');
                        } catch (e) {
                          print('⚠️ 포커스 활성화 중 오류: $e');
                        }

                        print('🚀 API 호출 시작...');
                        sessionId = await ApiGame.startGame(1);

                        if (sessionId != null && mounted) {
                          print('✅ API 성공, sessionId: $sessionId');

                          // 즉시 상태 업데이트 시도
                          setState(() {
                            gameStarted = true;
                          });
                          print('✅ setState 즉시 실행됨');

                          // 백업으로 PostFrameCallback 사용
                          if (!mounted) return;
                          WidgetsBinding.instance.addPostFrameCallback((_) {
                            if (mounted) {
                              setState(() {
                                gameStarted = true;
                              });
                              print('✅ PostFrameCallback setState 실행됨');
                            }
                          });
                        } else {
                          print(
                              '❌ 게임 시작 실패 - sessionId: $sessionId, mounted: $mounted');
                        }
                      },
                      child: Container(
                        width: 200,
                        height: 60,
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Colors.green, Colors.lightGreen],
                          ),
                          borderRadius: BorderRadius.circular(30),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.3),
                              blurRadius: 10,
                              offset: const Offset(0, 5),
                            ),
                          ],
                        ),
                        child: const Center(
                          child: Text(
                            '게임 시작',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              fontFamily: 'NaverNanumSquareRound',
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
