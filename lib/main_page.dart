import 'dart:convert';
import 'package:bird_raise_app/api/api_bag.dart';
import 'package:bird_raise_app/api/api_main.dart';
import 'package:bird_raise_app/api/api_bird.dart';
import 'package:bird_raise_app/component/bag_window.dart';
import 'package:bird_raise_app/gui_click_pages/bag_page.dart';
import 'package:bird_raise_app/gui_click_pages/book_page.dart';
import 'package:bird_raise_app/model/gold_model.dart';
import 'package:bird_raise_app/model/experience_level.dart';
import 'package:bird_raise_app/model/new_item_model.dart';
import 'package:bird_raise_app/services/timer_service.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:gif/gif.dart';
import 'package:provider/provider.dart';
import '../gui_click_pages/shop_page.dart';
import 'dart:async';
import '../gui_click_pages/adventure_page.dart';
import '../gui_click_pages/crafting_page.dart';
import 'package:audioplayers/audioplayers.dart';

/// 타이머만을 위한 별도 위젯
class TimerWidget extends StatefulWidget {
  const TimerWidget({super.key});

  @override
  State<TimerWidget> createState() => _TimerWidgetState();
}

class _TimerWidgetState extends State<TimerWidget> {
  String _elapsedTimeString = '00:00';
  final TimerService _timerService = TimerService();

  @override
  void initState() {
    super.initState();
    _timerService.addListener(_onTimerUpdate);
  }

  void _onTimerUpdate(Duration elapsedTime) {
    if (mounted) {
      setState(() {
        _elapsedTimeString = _timerService.formattedElapsedTime;
      });
    }
  }

  @override
  void dispose() {
    _timerService.removeListener(_onTimerUpdate);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.7),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.access_time,
            color: Colors.white,
            size: 16,
          ),
          const SizedBox(width: 6),
          Text(
            _elapsedTimeString,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.bold,
              fontFamily: 'NaverNanumSquareRound',
            ),
          ),
        ],
      ),
    );
  }
}

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  _MainPageState createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> with TickerProviderStateMixin {
  final TextEditingController _goldController = TextEditingController();
  final TextEditingController _nicknameController = TextEditingController();
  late final GifController controller;
  late AudioPlayer backgroundMusicPlayer;
  String gold = '0';
  int starCoin = 0;
  String nickname = "유저1";
  int exp = 0;
  int maxExp = 0;
  int minExp = 0;
  int level = 0;
  int birdHungry = 5; // 기본값 설정 (0-10 범위)
  int birdThirst = 5; // 기본값 설정 (0-10 범위)
  bool isBagVisible = false;
  bool isLoading = true;
  bool isFeeding = false;
  List<Map<String, String>> bagItems = [];

  List<String> imagePaths = [];
  List<String> itemAmounts = [];
  List<String> itemCodes = [];

  // 새의 생성 시간 관련 변수
  String? birdCreatedAt;
  String birdAgeString = '0분';

  // BGM 상태 추적
  bool isBGMPlaying = false;
  bool isInitialized = false; // 초기화 여부 추적

  @override
  void initState() {
    super.initState();
    controller = GifController(vsync: this);

    // BGM 플레이어 초기화
    backgroundMusicPlayer = AudioPlayer();

    // 비동기 메서드 실행
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeData();
      context.read<GoldModel>().fetchGold();
      _loadBagItems();
      // 새 아이템 목록 로드
      context.read<NewItemModel>().loadNewItems();

      // 디버깅용: 앱 시작 시 새 아이템 데이터 초기화 (필요시 주석 해제)
      // context.read<NewItemModel>().clearAllNewItemsFromStorage();
    });

    // gif 루프
    controller.repeat(period: Duration(milliseconds: 1300));

    // 새의 나이를 1분마다 업데이트
    Timer.periodic(const Duration(minutes: 1), (timer) {
      if (mounted) {
        _updateBirdAge();
      } else {
        timer.cancel();
      }
    });
  }

  // BGM 초기화 및 재생
  Future<void> _initializeBGM() async {
    if (isInitialized) return; // 이미 초기화되었다면 중복 실행 방지

    try {
      await backgroundMusicPlayer.play(AssetSource('sounds/main_page_BGM.mp3'));
      await backgroundMusicPlayer.setReleaseMode(ReleaseMode.loop);
      await backgroundMusicPlayer.setVolume(0.3); // 30% 볼륨으로 설정
      setState(() {
        isBGMPlaying = true;
        isInitialized = true;
      });
      print('메인 페이지 BGM 시작 성공');
    } catch (e) {
      print('메인 페이지 BGM 시작 실패: $e');
    }
  }

  // BGM 중지
  Future<void> _stopBGM() async {
    try {
      await backgroundMusicPlayer.stop();
      setState(() {
        isBGMPlaying = false;
      });
      print('메인 페이지 BGM 중지 성공');
    } catch (e) {
      print('메인 페이지 BGM 중지 실패: $e');
      // 실패하더라도 상태는 업데이트
      setState(() {
        isBGMPlaying = false;
      });
    }
  }

  // BGM 재생
  Future<void> _resumeBGM() async {
    if (isBGMPlaying) return; // 이미 재생 중이면 중복 실행 방지

    try {
      await backgroundMusicPlayer.play(AssetSource('sounds/main_page_BGM.mp3'));
      await backgroundMusicPlayer.setReleaseMode(ReleaseMode.loop);
      await backgroundMusicPlayer.setVolume(0.3);
      setState(() {
        isBGMPlaying = true;
      });
      print('메인 페이지 BGM 재생 성공');
    } catch (e) {
      print('메인 페이지 BGM 재생 실패: $e');
    }
  }

  Future<void> _initializeData() async {
    try {
      final responseData = await ApiMain.fetchUserInfo();

      if (responseData != null && mounted) {
        int goldAmount = responseData['gold'];
        context.read<GoldModel>().updateGold(goldAmount);
        setState(() {
          nickname = utf8.decode(responseData['nickname'].toString().codeUnits);
          level = responseData['userLevel'];
          starCoin = responseData['starCoin'];
          exp = responseData['userExp'];
          minExp = responseData['minExp'];
          maxExp = responseData['maxExp'];
          birdHungry = responseData['birdHungry'] ?? 5; // 새의 배고픔 상태
          birdThirst = responseData['birdThirst'] ?? 5; // 새의 목마름 상태
          birdCreatedAt = responseData['createdAt'];
          isLoading = false;
        });
      } else {
        _showError('API 호출에 실패했습니다.');
      }
    } catch (e) {
      print('❌ 예외 발생: $e');
      _showError('서버 연결에 실패했습니다.');
    }
  }

  Future<void> _handleLogout() async {
    try {
      await ApiMain.logout();
      Get.offAllNamed('/');
    } catch (e) {
      print('❌ 로그아웃 실패: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('로그아웃 중 문제가 발생했습니다.')),
      );
    }
  }

  void _showError(String message) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: const TextStyle(fontFamily: 'NanumSquareRound'),
        ),
        backgroundColor: Colors.redAccent.withOpacity(0.9),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _showCopyrightInfo() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.0),
          ),
          child: Container(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  children: [
                    Icon(Icons.music_note, color: Colors.blue, size: 24),
                    SizedBox(width: 8),
                    Text(
                      '🎵 사용한 사운드 효과',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'NaverNanumSquareRound',
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                const Text(
                  '• "국악 배경음악 #131"\n'
                  '  저작자: 주식회사 아이티앤\n'
                  '  출처: https://gongu.copyright.or.kr/gongu/wrt/wrt/view.do?wrtSn=13379714&menuNo=200020\n'
                  '  라이선스: CC BY (저작자 표시)\n\n'
                  '• "국악 효과음 #536"\n'
                  '  저작자: 주식회사 아이티앤\n'
                  '  출처: https://gongu.copyright.or.kr/gongu/wrt/wrt/view.do?wrtSn=13380369&menuNo=200020\n'
                  '  라이선스: CC BY (저작자 표시)\n\n'
                  '• 타이라 고모리 무료 음원\n'
                  '  출처: https://taira-komori.jpn.org/freesoundkr.html',
                  style: TextStyle(
                    fontSize: 14,
                    fontFamily: 'NaverNanumSquareRound',
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text(
                        '닫기',
                        style: TextStyle(
                          fontSize: 16,
                          fontFamily: 'NaverNanumSquareRound',
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _handleFeedGif() async {
    setState(() {
      isFeeding = true;
    });

    await Future.delayed(const Duration(seconds: 2));
    if (mounted) {
      setState(() {
        isFeeding = false;
      });
    }
  }

  String formatKoreanNumber(int number) {
    if (number >= 100000000) {
      return (number / 100000000).toStringAsFixed(1) + '억';
    } else if (number >= 10000000) {
      return (number / 10000000).toStringAsFixed(1) + '천만';
    } else if (number >= 1000000) {
      return (number / 1000000).toStringAsFixed(1) + '백만';
    } else if (number >= 10000) {
      return (number / 10000).toStringAsFixed(1) + '만';
    } else if (number >= 1000) {
      return (number / 1000).toStringAsFixed(1) + '천';
    } else {
      return number.toString();
    }
  }

  Future<void> _loadBagItems() async {
    setState(() {});
    try {
      final items = await fetchBagData();
      setState(() {
        imagePaths = items.map((e) => e['imagePath'] ?? '').toList();
        itemAmounts = items.map((e) => e['amount'] ?? '').toList();
        itemCodes = items.map((e) => e['itemCode'] ?? '').toList();
      });
    } catch (e) {
      print('❌ 가방 데이터 로딩 실패: $e');
      _showError('가방 아이템을 불러오지 못했습니다.');
      setState(() {});
    }
  }

  /// 새의 나이를 업데이트하는 메서드
  void _updateBirdAge() {
    if (birdCreatedAt != null) {
      setState(() {
        birdAgeString = ApiBird.formatBirdAge(birdCreatedAt!);
      });
    }
  }

  /// 새의 상태 정보를 가져오는 메서드
  Future<void> _fetchBirdState() async {
    try {
      final response = await ApiBird.getBirdState();
      if (response != null && mounted) {
        setState(() {
          birdHungry = response['hungry'] ?? birdHungry;
          birdThirst = response['thirst'] ?? birdThirst;
          birdCreatedAt = response['createdAt'];
        });

        // 새의 나이 업데이트
        _updateBirdAge();
      }
    } catch (e) {
      print('❌ 새 상태 가져오기 실패: $e');
    }
  }

  @override
  void dispose() {
    _goldController.dispose();
    _nicknameController.dispose();
    controller.dispose(); // GifController dispose 추가
    backgroundMusicPlayer.dispose(); // BGM 플레이어 dispose 추가
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final goldModel = context.watch<GoldModel>();
    final newItemModel = context.watch<NewItemModel>();
    final gold = goldModel.gold;
    final formattedGold = formatKoreanNumber(gold);

    // 처음 로드될 때만 BGM 초기화
    if (!isInitialized) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _initializeBGM();
      });
    } else if (!isBGMPlaying) {
      // 메인 페이지로 돌아왔을 때 BGM이 중지된 상태라면 재생
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _resumeBGM();
      });
    }

    return Scaffold(
      body: Stack(
        children: [
          // 전체 화면 배경
          Positioned.fill(
            child: Image.asset(
              MediaQuery.of(context).size.width >
                      MediaQuery.of(context).size.height
                  ? 'images/background/main_page_length_background.png' // 가로 모드 (가로 길이가 더 클 때)
                  : 'images/background/main_page_width_background.png', // 세로 모드 (세로 길이가 더 클 때)
              fit: BoxFit.fill, // 화면 크기에 맞게 이미지 늘림 (세로 압축 가능)
            ),
          ),
          // 바닥에 러그 배치
          Positioned(
            top: MediaQuery.of(context).size.height / 2 - 110,
            left: MediaQuery.of(context).size.width / 2 - 295,
            child: Image.asset(
              'images/floor-blue-rug.png',
              width: 600,
              height: 750,
              fit: BoxFit.contain,
            ),
          ),
          // 헤더를 Stack의 맨 위에 고정
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 프로필+경험치바 영역
                  Expanded(
                    flex: 2,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        // 프로필 영역
                        SizedBox(
                          width: 114,
                          height: 48,
                          child: Stack(
                            children: [
                              // 배경 이미지
                              Positioned.fill(
                                child: Image.asset(
                                  'images/GUI/profile_background_GUI.png',
                                  fit: BoxFit.fill,
                                ),
                              ),
                              // 테두리 이미지 (왼쪽 48x48)
                              Positioned(
                                left: 0,
                                top: 0,
                                width: 48,
                                height: 48,
                                child: Image.asset(
                                  'images/GUI/profile_border_GUI.png',
                                  fit: BoxFit.contain,
                                ),
                              ),
                              // 프로필 이미지
                              Positioned(
                                left: 5,
                                top: 5,
                                width: 38,
                                height: 38,
                                child: Image.network(
                                  'https://birdgamebukkit.s3.ap-northeast-2.amazonaws.com/birdgame-profile/test_profile.png',
                                  width: 38,
                                  height: 38,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) {
                                    return Container(
                                      width: 38,
                                      height: 38,
                                      decoration: BoxDecoration(
                                        color: Colors.blue[300],
                                      ),
                                      child: const Icon(
                                        Icons.person,
                                        color: Colors.white,
                                        size: 20,
                                      ),
                                    );
                                  },
                                  loadingBuilder:
                                      (context, child, loadingProgress) {
                                    if (loadingProgress == null) return child;
                                    return Container(
                                      width: 38,
                                      height: 38,
                                      decoration: BoxDecoration(
                                        color: Colors.grey[300],
                                      ),
                                      child: const Center(
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              ),
                              // 닉네임/레벨 텍스트
                              Positioned(
                                left: 52,
                                top: 8,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      nickname,
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 10,
                                        fontFamily: 'NaverNanumSquareRound',
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      'Lv. $level',
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        // 경험치 바
                        Container(
                          width: 114,
                          height: 16,
                          decoration: BoxDecoration(
                            color: Colors.grey[300],
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Stack(
                            children: [
                              FractionallySizedBox(
                                alignment: Alignment.centerLeft,
                                widthFactor: ExperienceLevel.calculateProgress(
                                    exp, level, maxExp, minExp),
                                child: Container(
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(10),
                                    gradient: const LinearGradient(
                                      begin: Alignment.topCenter,
                                      end: Alignment.bottomCenter,
                                      colors: [
                                        Colors.green,
                                        Colors.lightGreen,
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                              // 필요하다면 경험치 텍스트 등 추가 가능
                            ],
                          ),
                        ),
                        const SizedBox(height: 8), // 경험치바와 타이머 사이 간격
                        // 타이머 표시
                        TimerWidget(),
                      ],
                    ),
                  ),
                  // 골드
                  Expanded(
                    flex: 2,
                    child: Container(
                      margin: EdgeInsets.only(
                          left: MediaQuery.of(context).size.width * 0.02),
                      decoration: const BoxDecoration(
                        image: DecorationImage(
                          image: AssetImage('images/GUI/gold_GUI.png'),
                          fit: BoxFit.contain,
                        ),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Align(
                                  alignment: Alignment.centerRight,
                                  child: FittedBox(
                                    fit: BoxFit.scaleDown,
                                    child: Text(
                                      formattedGold,
                                      style: const TextStyle(
                                        color: Colors.black,
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        fontFamily: 'NaverNanumSquareRound',
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              GestureDetector(
                                onTap: () {
                                  print('골드 충전 버튼 클릭');
                                },
                                child: Image.asset(
                                  'images/GUI/gold_plus_button_GUI.png',
                                  height: MediaQuery.of(context).size.height *
                                      0.024,
                                  fit: BoxFit.contain,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  // 스타코인
                  Expanded(
                    flex: 2,
                    child: Container(
                      margin: EdgeInsets.only(
                          left: MediaQuery.of(context).size.width * 0.02),
                      decoration: const BoxDecoration(
                        image: DecorationImage(
                          image: AssetImage('images/GUI/star_coin_GUI.png'),
                          fit: BoxFit.contain,
                        ),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Align(
                                  alignment: Alignment.centerRight,
                                  child: FittedBox(
                                    fit: BoxFit.scaleDown,
                                    child: Text(
                                      '$starCoin',
                                      style: const TextStyle(
                                        color: Colors.black,
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        fontFamily: 'NaverNanumSquareRound',
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              GestureDetector(
                                onTap: () {
                                  print('스타 코인 충전 버튼 클릭');
                                },
                                child: Image.asset(
                                  'images/GUI/star_coin_plus_button_GUI.png',
                                  height: MediaQuery.of(context).size.height *
                                      0.024,
                                  fit: BoxFit.contain,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  // 설정 버튼
                  Expanded(
                    flex: 1,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        GestureDetector(
                          onTap: () {
                            print('설정 아이콘 클릭');
                            showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                return Dialog(
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8.0),
                                  ),
                                  child: Container(
                                    height: 250,
                                    width: 300,
                                    padding: const EdgeInsets.all(20),
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        ElevatedButton(
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: Colors.red,
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 50,
                                              vertical: 15,
                                            ),
                                          ),
                                          onPressed: _handleLogout,
                                          child: const Text(
                                            '로그아웃',
                                            style: TextStyle(
                                              fontSize: 18,
                                              fontFamily:
                                                  'NaverNanumSquareRound',
                                              color: Colors.white,
                                            ),
                                          ),
                                        ),
                                        const SizedBox(height: 20),
                                        ElevatedButton(
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: Colors.blue,
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 30,
                                              vertical: 10,
                                            ),
                                          ),
                                          onPressed: () {
                                            Navigator.pop(context);
                                            _showCopyrightInfo();
                                          },
                                          child: const Text(
                                            '저작물 정보',
                                            style: TextStyle(
                                              fontSize: 14,
                                              fontFamily:
                                                  'NaverNanumSquareRound',
                                              color: Colors.white,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            );
                          },
                          child: Container(
                            width: MediaQuery.of(context).size.width * 0.09,
                            height: MediaQuery.of(context).size.width * 0.09,
                            decoration: const BoxDecoration(
                              image: DecorationImage(
                                image: AssetImage('images/setting_button.png'),
                                fit: BoxFit.contain,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 8), // 설정 버튼과 post 버튼 사이 간격
                        // post_button.png
                        GestureDetector(
                          onTap: () {
                            print('post 버튼 클릭');
                          },
                          child: Container(
                            width: MediaQuery.of(context).size.width * 0.09,
                            height: MediaQuery.of(context).size.width * 0.09,
                            decoration: const BoxDecoration(
                              image: DecorationImage(
                                image: AssetImage('images/post_button.png'),
                                fit: BoxFit.contain,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 8), // post 버튼과 제작 아이콘 사이 간격
                        // 제작/조합 아이콘
                        GestureDetector(
                          onTap: () async {
                            print('제작/조합 아이콘 클릭');
                            await _stopBGM();
                            await Future.delayed(
                                const Duration(milliseconds: 100)); // BGM 중지 대기
                            Get.off(() => const CraftingPage());
                          },
                          child: Container(
                            width: MediaQuery.of(context).size.width * 0.09,
                            height: MediaQuery.of(context).size.width * 0.09,
                            decoration: BoxDecoration(
                              color: Colors.orange.withOpacity(0.8),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Icon(
                              Icons.build,
                              color: Colors.white,
                              size: 24,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          // 새 GIF 배치
          Positioned(
            top: MediaQuery.of(context).size.height / 2 - -60, // 이전 y좌표 유지
            left: MediaQuery.of(context).size.width / 2 - 160, // x좌표를 더 왼쪽으로 이동
            child: Column(
              children: [
                Row(
                  children: [
                    // 배고픔 게이지 (왼쪽)
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.restaurant,
                            size: 20, color: Colors.white),
                        const SizedBox(height: 4),
                        SizedBox(
                          height: 100,
                          width: 20,
                          child: RotatedBox(
                            quarterTurns: -1,
                            child: LinearProgressIndicator(
                              value: birdHungry / 100,
                              backgroundColor: Colors.grey[200],
                              valueColor: const AlwaysStoppedAnimation<Color>(
                                  Colors.orange),
                              minHeight: 20,
                            ),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(7),
                          ),
                          child: Text(
                            '$birdHungry/100',
                            style: const TextStyle(fontSize: 12),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(width: 5), // 배고픔 게이지와 새 사이 간격
                    // 새 GIF
                    Gif(
                      controller: controller,
                      image: AssetImage(
                        isFeeding
                            ? 'images/birds/GIF/Omoknoonii/bird_Omoknoonii_feed_behavior.gif'
                            : 'images/birds/GIF/Omoknoonii/bird_Omoknoonii.gif',
                      ),
                      width: 200,
                      height: 200,
                      fit: BoxFit.contain,
                    ),
                    const SizedBox(width: 5), // 새와 목마름 게이지 사이 간격
                    // 목마름 게이지 (오른쪽)
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.water_drop,
                            size: 20, color: Colors.white),
                        const SizedBox(height: 4),
                        SizedBox(
                          height: 100,
                          width: 20,
                          child: RotatedBox(
                            quarterTurns: -1,
                            child: LinearProgressIndicator(
                              value: birdThirst / 100,
                              backgroundColor: Colors.grey[200],
                              valueColor: const AlwaysStoppedAnimation<Color>(
                                  Colors.blue),
                              minHeight: 20,
                            ),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(7),
                          ),
                          child: Text(
                            '$birdThirst/100',
                            style: const TextStyle(fontSize: 12),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 10), // 새와 상태 표시 사이 간격
              ],
            ),
          ),
          if (isBagVisible)
            BagWindow(
              imagePaths: imagePaths,
              itemAmounts: itemAmounts,
              itemCodes: itemCodes,
              onFeed: (itemCode) async {
                try {
                  final response = await ApiBird.feed(itemCode);
                  if (response != null) {
                    print('먹이 주기 API 응답: $response');

                    setState(() {
                      // API 응답에서 가능한 모든 필드명 시도
                      birdHungry = response['birdHungry'] ??
                          response['hungry'] ??
                          birdHungry;
                      birdThirst = response['birdThirst'] ??
                          response['thirst'] ??
                          birdThirst;
                    });

                    print('업데이트된 상태 - 배고픔: $birdHungry, 목마름: $birdThirst');
                    _handleFeedGif();
                  }
                } catch (e) {
                  print('❌ 아이템 사용 중 오류 발생: $e');
                }
              },
            ),
          // 새의 나이 표시 (하단 네비게이션 바 바로 위)
          Positioned(
            bottom: 80, // 네비게이션 바 높이(70) + 여백(10)
            right: 16,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.7),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.pets,
                    color: Colors.white,
                    size: 16,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    '태어난지 : $birdAgeString',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'NaverNanumSquareRound',
                    ),
                  ),
                ],
              ),
            ),
          ),
          // 하단 네비게이션 바
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              height: 70,
              child: Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () async {
                        await _stopBGM();
                        await Future.delayed(
                            const Duration(milliseconds: 100)); // BGM 중지 대기
                        await Get.off(() => const BookPage());
                      },
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          Container(
                            width: double.infinity,
                            height: double.infinity,
                            child: Image.asset(
                              'images/GUI/background_GUI.png',
                              fit: BoxFit.fill,
                            ),
                          ),
                          FractionallySizedBox(
                            widthFactor: 0.90,
                            heightFactor: 0.90,
                            child: Image.asset(
                              'images/GUI/book_GUI.png',
                              fit: BoxFit.contain,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Expanded(
                    child: GestureDetector(
                      onTap: () async {
                        await _stopBGM();
                        await Future.delayed(
                            const Duration(milliseconds: 100)); // BGM 중지 대기
                        await Get.to(() => const AdventurePage());
                      },
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          Container(
                            width: double.infinity,
                            height: double.infinity,
                            child: Image.asset(
                              'images/GUI/background_GUI.png',
                              fit: BoxFit.fill,
                            ),
                          ),
                          FractionallySizedBox(
                            widthFactor: 0.90,
                            heightFactor: 0.90,
                            child: Image.asset(
                              'images/GUI/adventure_GUI.png',
                              fit: BoxFit.contain,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Expanded(
                    child: GestureDetector(
                      onTap: () async {
                        await _stopBGM();
                        await Future.delayed(
                            const Duration(milliseconds: 100)); // BGM 중지 대기
                        await Get.to(() => const ShopPage());
                        await goldModel.fetchGold(); // gold 값 갱신
                      },
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          Container(
                            width: double.infinity,
                            height: double.infinity,
                            child: Image.asset(
                              'images/GUI/background_GUI.png',
                              fit: BoxFit.fill,
                            ),
                          ),
                          FractionallySizedBox(
                            widthFactor: 0.90,
                            heightFactor: 0.90,
                            child: Image.asset(
                              'images/GUI/shop_GUI.png',
                              fit: BoxFit.contain,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Expanded(
                    child: GestureDetector(
                      onTap: () async {
                        await _stopBGM();
                        await Future.delayed(
                            const Duration(milliseconds: 100)); // BGM 중지 대기
                        await Get.to(() => const BagPage());
                        await goldModel.fetchGold(); // gold 값 갱신
                      },
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          Container(
                            width: double.infinity,
                            height: double.infinity,
                            child: Image.asset(
                              'images/GUI/background_GUI.png',
                              fit: BoxFit.fill,
                            ),
                          ),
                          Stack(
                            alignment: Alignment.center,
                            children: [
                              FractionallySizedBox(
                                widthFactor: 0.90,
                                heightFactor: 0.90,
                                child: Image.asset(
                                  'images/GUI/bag_GUI.png',
                                  fit: BoxFit.contain,
                                ),
                              ),
                              // 새 아이템이 있을 때 표시 (bag_GUI.png 기준으로 위치)
                              if (newItemModel.newItems.isNotEmpty)
                                Positioned(
                                  top: 4,
                                  left: 4,
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 6, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: Colors.red,
                                      borderRadius: BorderRadius.circular(8),
                                      border: Border.all(
                                          color: Colors.white, width: 1),
                                    ),
                                    child: const Text(
                                      'NEW',
                                      style: TextStyle(
                                        color: Colors.yellow,
                                        fontSize: 10,
                                        fontWeight: FontWeight.bold,
                                        fontFamily: 'NaverNanumSquareRound',
                                      ),
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            top: MediaQuery.of(context).size.height / 2 - 24, // 아이콘 높이 절반만큼 위
            right: 16,
            child: GestureDetector(
              onTap: () async {
                setState(() => isBagVisible = !isBagVisible);
                if (isBagVisible) await _loadBagItems();
              },
              child: Image.asset(
                'images/GUI/bag_GUI.png',
                width: 48,
                height: 48,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
