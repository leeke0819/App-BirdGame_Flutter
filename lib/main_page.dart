import 'dart:convert';
import 'package:bird_raise_app/api/api_bag.dart';
import 'package:bird_raise_app/api/api_main.dart';
import 'package:bird_raise_app/component/bag_window.dart';
import 'package:bird_raise_app/gui_click_pages/bag_page.dart';
import 'package:bird_raise_app/model/gold_model.dart';
import 'package:bird_raise_app/model/experience_level.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:gif/gif.dart';
import 'package:provider/provider.dart';
import '../gui_click_pages/shop_page.dart';
import '../component/bird_status.dart';

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  _MainPageState createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> with TickerProviderStateMixin {
  final TextEditingController _goldController = TextEditingController();
  final TextEditingController _nicknameController = TextEditingController();
  late final GifController controller;
  String gold = '0';
  int starCoin = 0;
  String nickname = "유저1";
  int exp = 0;
  int maxExp = 0;
  int minExp = 0;
  int level = 0;
  int birdHungry = 5;  // 기본값 설정 (0-10 범위)
  int birdThirst = 5;  // 기본값 설정 (0-10 범위)
  bool isBagVisible = false;
  bool isLoading = true;
  bool isFeeding = false;
  List<Map<String, String>> bagItems = [];

  List<String> imagePaths = [];
  List<String> itemAmounts = [];
  List<String> itemCodes = [];

  @override
  void initState() {
    super.initState();
    controller = GifController(vsync: this);

    // 비동기 메서드 실행
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeData();
      context.read<GoldModel>().fetchGold();
      _loadBagItems();
    });

    // gif 루프
    controller.repeat(period: Duration(milliseconds: 1300));
  }

  Future<void> _initializeData() async {
    try {
      final responseData = await ApiMain.fetchUserInfo();

      if (responseData != null && mounted) {
        int goldAmount = responseData['gold'];
        context.read<GoldModel>().updateGold(goldAmount);
        print(responseData);
        setState(() {
          nickname = utf8.decode(responseData['nickname'].toString().codeUnits);
          level = responseData['userLevel'];
          starCoin = responseData['starCoin'];
          exp = responseData['userExp'];
          minExp = responseData['minExp'];
          maxExp = responseData['maxExp'];
          isLoading = false;
        });
        print("EXP: $exp");
        print("Min EXP: $minExp");
        print("Max EXP: $maxExp");
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

  void _handleFeed() async {
    if (isFeeding) return; // 중복 방지

    setState(() {
      isFeeding = true; // 새 이미지 feed_behavior.gif로 전환
      // 임시로 상태 업데이트 (실제로는 API 응답에 따라 업데이트해야 함)
      birdHungry = (birdHungry + 2).clamp(0, 10);
      birdThirst = (birdThirst + 2).clamp(0, 10);
    });

    await Future.delayed(const Duration(seconds: 2));

    if (mounted) {
      setState(() {
        isFeeding = false; // 다시 기본 이미지로 복귀
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

  @override
  void dispose() {
    _goldController.dispose();
    _nicknameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final goldModel = context.watch<GoldModel>();
    final gold = goldModel.gold;
    final formattedGold = formatKoreanNumber(gold);

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

          // AppBar 역할을 하는 커스텀 위젯
          Positioned(
            top: -50,
            left: -8,
            right: 0,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    flex: 1,
                    child: Container(
                      height: 80,
                      color: Colors.grey,
                      child: Column(
                        children: [
                          Flexible(
                            flex: 4,
                            child: Container(
                              height: 80,
                              child: Stack(
                                children: [
                                  // 배경 이미지
                                  Positioned.fill(
                                    child: Image.asset(
                                      'images/GUI/profile_background_GUI.png',
                                      fit: BoxFit.fill,
                                    ),
                                  ),
                                  // 프로필 테두리
                                  Positioned.fill(
                                    child: Image.asset(
                                      'images/GUI/profile_border_GUI.png',
                                      fit: BoxFit.fill,
                                    ),
                                  ),
                                  // 프로필 내용
                                  Positioned(
                                    left: 8, // 왼쪽 여백
                                    top: 6.5,  // 위쪽 여백
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.start,
                                      children: [
                                        Container(
                                          width: 50,
                                          height: 50,
                                          decoration: const BoxDecoration(
                                            color: Colors.white,
                                          ),
                                          child: Image.asset(
                                            'images/test_profile.png', // 프로필 이미지 경로
                                            fit: BoxFit.cover,
                                          ),
                                        ),

                                        // 프로필과 텍스트 사이 여백
                                        const SizedBox(width: 15), // 여백 추가
                                        
                                        // Lv. 과 이름 텍스트
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.end,
                                          children: [
                                            Column(
                                              crossAxisAlignment: CrossAxisAlignment.end,
                                              children: [
                                                Text(
                                                  nickname,
                                                  style: const TextStyle(
                                                    color: Colors.white,
                                                    fontSize: 14,
                                                    fontFamily: 'NaverNanumSquareRound',
                                                  ),
                                                ),
                                                const SizedBox(height: 4),
                                                Text(
                                                  'Lv. ' + level.toString(),
                                                  style: const TextStyle(
                                                    color: Colors.white,
                                                    fontSize: 16,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          Flexible(
                            flex: 1,
                            child: Container(
                              height: 20,
                              margin: const EdgeInsets.only(top: 8), // 아래로 살짝 이동
                              child: Stack(
                                children: [
                                  // 배경 이미지 (회색)
                                  Positioned.fill(
                                    child: Image.asset(
                                      'images/GUI/profile_exp_bar_background_GUI.png',
                                      fit: BoxFit.fill,
                                      filterQuality: FilterQuality.none,
                                    ),
                                  ),
                                  // 경험치 채워지는 이미지 (초록색)
                                  Positioned.fill(
                                    child: FractionallySizedBox(
                                      alignment: Alignment.centerLeft,
                                      widthFactor:
                                          ExperienceLevel.calculateProgress(
                                              exp, level, maxExp, minExp),
                                      child: Image.asset(
                                        'images/GUI/profile_exp_bar_GUI.png',
                                        fit: BoxFit.fill,
                                        filterQuality: FilterQuality.none,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    flex: 1,
                    child: Transform.translate(
                      offset: const Offset(5, 0), // 위치 조정 가능
                      child: SizedBox(
                        height: 153,
                        child: Column(
                          children: [
                            Stack(
                              alignment: Alignment.center,
                              children: [
                                Image.asset(
                                  'images/GUI/gold_GUI.png',
                                  width: 200,
                                  height: 100,
                                ),
                                Positioned(
                                  child: Container(
                                    width: 200,
                                    height: 100,
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 0),
                                    child: Row(
                                      children: [
                                        const SizedBox(
                                            width: 8), // 왼쪽 여백 (아이콘 등 필요시 조절)
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
                                                  fontFamily:
                                                      'NaverNanumSquareRound',
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 2),
                                        GestureDetector(
                                          onTap: () {
                                            print('골드 충전 버튼 클릭');
                                          },
                                          child: Image.asset(
                                            'images/GUI/gold_plus_button_GUI.png',
                                            width: MediaQuery.of(context)
                                                    .size
                                                    .width *
                                                0.052, // 화면 너비의 2%
                                            height: MediaQuery.of(context)
                                                    .size
                                                    .width *
                                                0.052, // 정사각형 비율 유지
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
                      ),
                    ),
                  ),
                  const SizedBox(width: 5),
                  Expanded(
                    flex: 1,
                    child: Transform.translate(
                      offset: const Offset(8, -26),
                      child: SizedBox(
                        height: 100,
                        child: Column(
                          children: [
                            Stack(
                              alignment: Alignment.center,
                              children: [
                                Image.asset(
                                  'images/GUI/star_coin_GUI.png',
                                  width: 200,
                                  height: 100,
                                ),
                                Positioned(
                                  child: Container(
                                    width: 200,
                                    height: 100,
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 0),
                                    child: Row(
                                      children: [
                                        const SizedBox(width: 8),
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
                                                  fontFamily:
                                                      'NaverNanumSquareRound',
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 6),
                                        GestureDetector(
                                          onTap: () {
                                            print('스타 코인 충전 버튼 클릭');
                                          },
                                          child: Image.asset(
                                            'images/GUI/star_coin_plus_button_GUI.png',
                                            width: MediaQuery.of(context)
                                                    .size
                                                    .width *
                                                0.052, // 화면 너비의 2%
                                            height: MediaQuery.of(context)
                                                    .size
                                                    .width *
                                                0.052,
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
                      ),
                    ),
                  ),
                  Transform.translate(
                    offset: const Offset(18, -22), // gold_GUI와 같은 높이로 설정
                    child: IconButton(
                      iconSize: MediaQuery.of(context).size.width *
                          0.037, // 50을 화면 너비의 3.7%로 변환
                      icon: Image.asset(
                        'images/setting_button.png',
                        width: MediaQuery.of(context).size.width *
                            0.09, // 40을 화면 너비의 3%로 변환
                        height: MediaQuery.of(context).size.width *
                            0.09, // 40을 화면 너비의 3%로 변환
                      ),
                      onPressed: () {
                        print('설정 아이콘 클릭');
                        showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return Dialog(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8.0),
                              ),
                              child: Container(
                                height: 200,
                                width: 300,
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    ElevatedButton(
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.red,
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 50,
                                          vertical: 15,
                                        ),
                                      ),
                                      child: const Text(
                                        '로그아웃',
                                        style: TextStyle(
                                          fontSize: 18,
                                          fontFamily: 'NaverNanumSquareRound',
                                          color: Colors.white,
                                        ),
                                      ),
                                      onPressed: _handleLogout,
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        );
                      },
                    ),
                  ),
                ],
              ),
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

          // 새 GIF 배치
          Positioned(
            top: MediaQuery.of(context).size.height / 2 - -60,
            left: MediaQuery.of(context).size.width / 2 - 95,
            child: Gif(
              controller: controller,
              image: AssetImage(
                isFeeding
                  ? 'images/bird_Omoknoonii_feed_behavior.gif'
                  : 'images/bird_Omoknoonii.gif',
              ),
              width: 200,
              height: 200,
              fit: BoxFit.contain,
            ),
          ),
          // 새 상태 표시
          Positioned(
            top: MediaQuery.of(context).size.height / 2 + 140,
            left: MediaQuery.of(context).size.width / 2 - 100,
            child: BirdStatus(
              birdHungry: birdHungry,
              birdThirst: birdThirst,
            ),
          ),
          if (isBagVisible)
            BagWindow(
              imagePaths: imagePaths,
              itemAmounts: itemAmounts,
              itemCodes: itemCodes,
              onFeed: _handleFeed,
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
                    child: Container(
                      color: Colors.blue[100],
                      child: const Center(
                        child: Text(
                          '도감',
                          style: TextStyle(fontFamily: 'NaverNanumSquareRound'),
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: Container(
                      color: Colors.green[100],
                      child: const Center(
                        child: Text(
                          '모험',
                          style: TextStyle(fontFamily: 'NaverNanumSquareRound'),
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: GestureDetector(
                      onTap: () async {
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
                          Image.asset(
                            'images/GUI/shop_GUI.png',
                            fit: BoxFit.contain,
                          ),
                        ],
                      ),
                    ),
                  ),
                  Expanded(
                    child: GestureDetector(
                      onTap: () async {
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
                          Image.asset(
                            'images/GUI/bag_GUI.png',
                            fit: BoxFit.contain,
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
                print("가방 아이콘 눌림");
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
