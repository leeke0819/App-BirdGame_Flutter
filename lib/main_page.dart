import 'dart:convert';
import 'dart:async';

import 'package:audioplayers/audioplayers.dart';
import 'package:bird_raise_app/api/api_bag.dart';
import 'package:bird_raise_app/api/api_bird.dart';
import 'package:bird_raise_app/api/api_main.dart';
import 'package:bird_raise_app/component/bag_window.dart';
import 'package:bird_raise_app/gui_click_pages/adventure_page.dart';
import 'package:bird_raise_app/gui_click_pages/bag_page.dart';
import 'package:bird_raise_app/gui_click_pages/book_page.dart';
import 'package:bird_raise_app/gui_click_pages/crafting_page.dart';
import 'package:bird_raise_app/gui_click_pages/shop_page.dart';
import 'package:bird_raise_app/main.dart';
import 'package:bird_raise_app/model/experience_level.dart';
import 'package:bird_raise_app/model/gold_model.dart';
import 'package:bird_raise_app/model/new_item_model.dart';
import 'package:bird_raise_app/services/timer_service.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:gif/gif.dart';
import 'package:provider/provider.dart';

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
    if (!mounted) return;
    setState(() {
      _elapsedTimeString = _timerService.formattedElapsedTime;
    });
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
          const Icon(Icons.access_time, color: Colors.white, size: 16),
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
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> with TickerProviderStateMixin {
  // Controllers
  final TextEditingController _goldController = TextEditingController();
  final TextEditingController _nicknameController = TextEditingController();
  late final GifController _gifController;

  // Audio
  late final AudioPlayer _bgmPlayer;
  late final AudioPlayer _sfxPlayer; // 버튼/에러 겸용 단일 SFX 플레이어

  // UI/State
  int starCoin = 0;
  String nickname = '유저1';
  int exp = 0;
  int maxExp = 0;
  int minExp = 0;
  int level = 0;
  int birdHungry = 5; // 0~100
  int birdThirst = 5; // 0~100
  bool isBagVisible = false;
  bool isLoading = true;
  bool isFeeding = false;

  List<String> imagePaths = [];
  List<String> itemAmounts = [];
  List<String> itemCodes = [];

  String? birdCreatedAt;
  String birdAgeString = '0분';

  // BGM 상태
  bool _bgmInitialized = false; // 초기 1회만 실행

  @override
  void initState() {
    super.initState();

    _gifController = GifController(vsync: this)
      ..repeat(period: const Duration(milliseconds: 1300));

    _bgmPlayer = AudioPlayer();
    _sfxPlayer = AudioPlayer();

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await _initializeData();
      if (!mounted) return;
      context.read<GoldModel>().fetchGold();
      _loadBagItems();
      context.read<NewItemModel>().loadNewItems();
      _initBGMOnce();
    });

    // 새의 나이 1분마다 업데이트
    Timer.periodic(const Duration(minutes: 1), (timer) {
      if (!mounted) return timer.cancel();
      _updateBirdAge();
    });
  }

  // ------------------- Data & API -------------------
  Future<void> _initializeData() async {
    try {
      final responseData = await ApiMain.fetchUserInfo();
      if (!mounted) return;

      if (responseData != null) {
        final goldAmount = responseData['gold'] as int;
        context.read<GoldModel>().updateGold(goldAmount);
        setState(() {
          nickname = utf8.decode(responseData['nickname'].toString().codeUnits);
          level = responseData['userLevel'] ?? 0;
          starCoin = responseData['starCoin'] ?? 0;
          exp = responseData['userExp'] ?? 0;
          minExp = responseData['minExp'] ?? 0;
          maxExp = responseData['maxExp'] ?? 0;
          birdHungry = responseData['birdHungry'] ?? 5;
          birdThirst = responseData['birdThirst'] ?? 5;
          birdCreatedAt = responseData['createdAt'];
          isLoading = false;
        });
        _updateBirdAge();
      } else {
        _showError('API 호출에 실패했습니다.');
      }
    } catch (e) {
      debugPrint('❌ 예외 발생: $e');
      _showError('서버 연결에 실패했습니다.');
    }
  }

  Future<void> _loadBagItems() async {
    try {
      final items = await fetchBagData();
      if (!mounted) return;
      setState(() {
        imagePaths = items.map((e) => e['imagePath'] ?? '').toList();
        itemAmounts = items.map((e) => e['amount'] ?? '').toList();
        itemCodes = items.map((e) => e['itemCode'] ?? '').toList();
      });
    } catch (e) {
      debugPrint('❌ 가방 데이터 로딩 실패: $e');
      _showError('가방 아이템을 불러오지 못했습니다.');
    }
  }

  Future<void> _fetchBirdState() async {
    try {
      final response = await ApiBird.getBirdState();
      if (!mounted || response == null) return;
      setState(() {
        birdHungry = response['hungry'] ?? birdHungry;
        birdThirst = response['thirst'] ?? birdThirst;
        birdCreatedAt = response['createdAt'];
      });
      _updateBirdAge();
    } catch (e) {
      debugPrint('❌ 새 상태 가져오기 실패: $e');
    }
  }

  // ------------------- BGM/SFX -------------------
  void _initBGMOnce() {
    if (_bgmInitialized) return;
    _bgmInitialized = true;
    _playBGM();
  }

  Future<void> _playBGM() async {
    try {
      await _bgmPlayer.stop();
      await _bgmPlayer.setReleaseMode(ReleaseMode.loop);
      await _bgmPlayer.setVolume(0.3);
      await _bgmPlayer.play(AssetSource('sounds/main_page_BGM.mp3'));
    } catch (e) {
      debugPrint('메인 페이지 BGM 시작 실패: $e');
    }
  }

  Future<void> _stopBGM() async {
    try {
      await _bgmPlayer.stop();
    } catch (e) {
      debugPrint('메인 페이지 BGM 중지 실패: $e');
    }
  }

  Future<void> _playClick() async {
    try {
      await _sfxPlayer.stop();
      await _sfxPlayer.setReleaseMode(ReleaseMode.stop);
      await _sfxPlayer.setVolume(0.5);
      await _sfxPlayer.play(AssetSource('sounds/button_click.wav'));
    } catch (e) {
      debugPrint('버튼 클릭 효과음 재생 실패: $e');
    }
  }

  Future<void> _playError() async {
    try {
      await _sfxPlayer.stop();
      await _sfxPlayer.setReleaseMode(ReleaseMode.stop);
      await _sfxPlayer.setVolume(0.5);
      // 파일명 오타/공백 방지: "error_or_fail_sound.wav" 로 정규화 권장
      await _sfxPlayer.play(AssetSource('sounds/error_or_fail_sound.wav'));
    } catch (e) {
      debugPrint('에러 효과음 재생 실패: $e');
    }
  }

  // ------------------- Helpers -------------------
  void _handleFeedGif() async {
    if (!mounted) return;
    setState(() => isFeeding = true);
    await Future.delayed(const Duration(seconds: 2));
    if (!mounted) return;
    setState(() => isFeeding = false);
  }

  String formatKoreanNumber(int number) {
    if (number >= 100000000)
      return (number / 100000000).toStringAsFixed(1) + '억';
    if (number >= 10000000)
      return (number / 10000000).toStringAsFixed(1) + '천만';
    if (number >= 1000000) return (number / 1000000).toStringAsFixed(1) + '백만';
    if (number >= 10000) return (number / 10000).toStringAsFixed(1) + '만';
    if (number >= 1000) return (number / 1000).toStringAsFixed(1) + '천';
    return number.toString();
  }

  void _updateBirdAge() {
    if (birdCreatedAt == null) return;
    setState(() {
      birdAgeString = ApiBird.formatBirdAge(birdCreatedAt!);
    });
  }

  Future<void> _handleLogout() async {
    try {
      await ApiMain.logout();
      if (!mounted) return;
      Get.offAll(() => const LoginPage());
    } catch (e) {
      debugPrint('❌ 로그아웃 실패: $e');
      _showError('로그아웃 중 문제가 발생했습니다.');
    }
  }

  void _showError(String message) async {
    await _playError();
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
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
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
                            fontSize: 16, fontFamily: 'NaverNanumSquareRound'),
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

  @override
  void dispose() {
    _goldController.dispose();
    _nicknameController.dispose();
    _gifController.dispose();
    _bgmPlayer.dispose();
    _sfxPlayer.dispose();
    super.dispose();
  }

  // ------------------- UI -------------------
  @override
  Widget build(BuildContext context) {
    final goldModel = context.watch<GoldModel>();
    final newItemModel = context.watch<NewItemModel>();
    final formattedGold = formatKoreanNumber(goldModel.gold);

    // 최초 1회만 BGM 구동 (build에서 재생/중지 로직을 넣지 않음)

    return Scaffold(
      body: Stack(
        children: [
          // 배경
          Positioned.fill(
            child: Image.asset(
              MediaQuery.of(context).size.width >
                      MediaQuery.of(context).size.height
                  ? 'images/background/main_page_length_background.png'
                  : 'images/background/main_page_width_background.png',
              fit: BoxFit.fill,
            ),
          ),

          // 바닥 러그
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

          // 헤더
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
                  // 프로필 + 경험치바 + 타이머
                  Expanded(
                    flex: 2,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        SizedBox(
                          width: 114,
                          height: 48,
                          child: Stack(
                            children: [
                              Positioned.fill(
                                child: Image.asset(
                                    'images/GUI/profile_background_GUI.png',
                                    fit: BoxFit.fill),
                              ),
                              Positioned(
                                left: 0,
                                top: 0,
                                width: 48,
                                height: 48,
                                child: Image.asset(
                                    'images/GUI/profile_border_GUI.png',
                                    fit: BoxFit.contain),
                              ),
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
                                      color: Colors.blue[300],
                                      child: const Icon(Icons.person,
                                          color: Colors.white, size: 20),
                                    );
                                  },
                                  loadingBuilder:
                                      (context, child, loadingProgress) {
                                    if (loadingProgress == null) return child;
                                    return Container(
                                      width: 38,
                                      height: 38,
                                      color: Colors.grey[300],
                                      child: const Center(
                                          child: CircularProgressIndicator(
                                              strokeWidth: 2)),
                                    );
                                  },
                                ),
                              ),
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
                                      colors: [Colors.green, Colors.lightGreen],
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 8),
                        const TimerWidget(),
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
                                onTap: () async {
                                  await _playClick();
                                  debugPrint('골드 충전 버튼 클릭');
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
                                onTap: () async {
                                  await _playClick();
                                  debugPrint('스타 코인 충전 버튼 클릭');
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

                  // 설정/저작물/제작 버튼
                  Expanded(
                    flex: 1,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        GestureDetector(
                          onTap: () async {
                            await _playClick();
                            showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                return Dialog(
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8.0)),
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
                                                horizontal: 50, vertical: 15),
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
                                                horizontal: 30, vertical: 10),
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
                        const SizedBox(height: 8),
                        GestureDetector(
                          onTap: () async {
                            await _playClick();
                            debugPrint('post 버튼 클릭');
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
                        const SizedBox(height: 8),
                        GestureDetector(
                          onTap: () async {
                            await _playClick();
                            await _stopBGM();
                            Get.off(() => const CraftingPage());
                          },
                          child: Container(
                            width: MediaQuery.of(context).size.width * 0.09,
                            height: MediaQuery.of(context).size.width * 0.09,
                            decoration: BoxDecoration(
                              color: Colors.orange.withOpacity(0.8),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Icon(Icons.build,
                                color: Colors.white, size: 24),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // 새 + 게이지
          Positioned(
            top: MediaQuery.of(context).size.height / 2 - -60,
            left: MediaQuery.of(context).size.width / 2 - 160,
            child: Column(
              children: [
                Row(
                  children: [
                    // 🍖 배고픔 게이지
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
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(10),
                                  child: LinearProgressIndicator(
                                    value: birdHungry / 100,
                                    backgroundColor: Colors.grey[200],
                                    valueColor:
                                        const AlwaysStoppedAnimation<Color>(
                                            Colors.orange),
                                    minHeight: 20,
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
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(width: 5),

                    // 🐦 새 GIF
                    Gif(
                      controller: _gifController,
                      image: AssetImage(
                        isFeeding
                            ? 'images/birds/GIF/Omoknoonii/bird_Omoknoonii_feed_behavior.gif'
                            : 'images/birds/GIF/Omoknoonii/bird_Omoknoonii.gif',
                      ),
                      width: 200,
                      height: 200,
                      fit: BoxFit.contain,
                    ),

                    const SizedBox(width: 5),

                    // 💧 목마름 게이지
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
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(10),
                                  child: LinearProgressIndicator(
                                    value: birdThirst / 100,
                                    backgroundColor: Colors.grey[200],
                                    valueColor:
                                        const AlwaysStoppedAnimation<Color>(
                                            Colors.blue),
                                    minHeight: 20,
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
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 10),
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
                  if (response == null) return;
                  setState(() {
                    birdHungry = response['birdHungry'] ??
                        response['hungry'] ??
                        birdHungry;
                    birdThirst = response['birdThirst'] ??
                        response['thirst'] ??
                        birdThirst;
                  });
                  _handleFeedGif();
                } catch (e) {
                  debugPrint('❌ 아이템 사용 중 오류 발생: $e');
                }
              },
            ),

          // 새의 나이
          Positioned(
            bottom: 80,
            right: 16,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.7),
                  borderRadius: BorderRadius.circular(8)),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.pets, color: Colors.white, size: 16),
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

          // 하단 네비게이션
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: SizedBox(
              height: 70,
              child: Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () async {
                        await _playClick();
                        await _stopBGM();
                        Get.off(() => const BookPage());
                      },
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          SizedBox(
                            width: double.infinity,
                            height: double.infinity,
                            child: Image.asset('images/GUI/background_GUI.png',
                                fit: BoxFit.fill),
                          ),
                          const FractionallySizedBox(
                            widthFactor: 0.90,
                            heightFactor: 0.90,
                            child: Image(
                                image: AssetImage('images/GUI/book_GUI.png'),
                                fit: BoxFit.contain),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Expanded(
                    child: GestureDetector(
                      onTap: () async {
                        await _playClick();
                        await _stopBGM();
                        Get.off(() => const AdventurePage());
                      },
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          SizedBox(
                            width: double.infinity,
                            height: double.infinity,
                            child: Image.asset('images/GUI/background_GUI.png',
                                fit: BoxFit.fill),
                          ),
                          const FractionallySizedBox(
                            widthFactor: 0.90,
                            heightFactor: 0.90,
                            child: Image(
                                image:
                                    AssetImage('images/GUI/adventure_GUI.png'),
                                fit: BoxFit.contain),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Expanded(
                    child: GestureDetector(
                      onTap: () async {
                        await _playClick();
                        await _stopBGM();
                        Get.off(() => const ShopPage());
                        await context.read<GoldModel>().fetchGold();
                      },
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          SizedBox(
                            width: double.infinity,
                            height: double.infinity,
                            child: Image.asset('images/GUI/background_GUI.png',
                                fit: BoxFit.fill),
                          ),
                          const FractionallySizedBox(
                            widthFactor: 0.90,
                            heightFactor: 0.90,
                            child: Image(
                                image: AssetImage('images/GUI/shop_GUI.png'),
                                fit: BoxFit.contain),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Expanded(
                    child: GestureDetector(
                      onTap: () async {
                        await _playClick();
                        await _stopBGM();
                        Get.off(() => const BagPage());
                        await context.read<GoldModel>().fetchGold();
                      },
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          SizedBox(
                            width: double.infinity,
                            height: double.infinity,
                            child: Image.asset('images/GUI/background_GUI.png',
                                fit: BoxFit.fill),
                          ),
                          Stack(
                            alignment: Alignment.center,
                            children: [
                              const FractionallySizedBox(
                                widthFactor: 0.90,
                                heightFactor: 0.90,
                                child: Image(
                                    image: AssetImage('images/GUI/bag_GUI.png'),
                                    fit: BoxFit.contain),
                              ),
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

          // 우측 플로팅 가방 버튼
          Positioned(
            top: MediaQuery.of(context).size.height / 2 - 24,
            right: 16,
            child: GestureDetector(
              onTap: () async {
                await _playClick();
                setState(() => isBagVisible = !isBagVisible);
                if (isBagVisible) await _loadBagItems();
              },
              child:
                  Image.asset('images/GUI/bag_GUI.png', width: 48, height: 48),
            ),
          ),
        ],
      ),
    );
  }
}
