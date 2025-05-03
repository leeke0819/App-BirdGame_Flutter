import 'dart:convert';
import 'package:bird_raise_app/gui_click_pages/bag_page.dart';
import 'package:bird_raise_app/model/gold_model.dart';
import 'package:bird_raise_app/token/chrome_token.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:gif/gif.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import '../gui_click_pages/shop_page.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:bird_raise_app/token/mobile_secure_token.dart';

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
  String? nickname;
  int exp = 0;
  int level = 0;

  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    controller = GifController(vsync: this);

    // 비동기 메서드 실행
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeData();
      context.read<GoldModel>().fetchGold();
    });

    // gif 루프
    controller.repeat(period: Duration(milliseconds: 1300));
  }

  Future<void> _initializeData() async {
    final url = Uri.parse('http://192.168.10.9:8080/api/v1/user');

    String? token;
    if (kIsWeb) {
      token = getChromeAccessToken();
    } else {
      token = await getAccessToken(); //1초짜리 print문
    }
    print("발급된 JWT: $token");
    String bearerToken = "Bearer $token";

    // 웹인지 모바일인지 검사
    if (kIsWeb) {
      print("현재 웹에서 실행 중입니다.");
    } else {
      print("현재 모바일(Android)에서 실행 중입니다.");
    }

    try {
      final response = await http.get(
        url,
        headers: {'Authorization': bearerToken},
      );

      // 응답이 성공적인지 아닌지 여부를 메시지 보내기
      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        print('API 호출 성공 : ${responseData}');

        int goldAmount = responseData['gold'];
        context.read<GoldModel>().updateGold(goldAmount);

        setState(() {
          nickname = responseData['nickname'];
          level = responseData['userLevel'];
          starCoin = responseData['starCoin'];
          isLoading = false;
        });
      } else {
        print('API 호출 실패 : ${response.statusCode}');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                'API 호출에 실패했습니다.',
                style: TextStyle(fontFamily: 'NanumSquareRound'),
              ),
            ),
          );
        }
      }
    } catch (e) {
      print('Error: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              '서버 연결에 실패했습니다.',
              style: TextStyle(fontFamily: 'NanumSquareRound'),
            ),
          ),
        );
      }
    }

    if (mounted) {
      Future.delayed(Duration.zero, () {
        print('로그인 성공!');
      });
    }
  }

  Future<void> _handleLogout() async {
    // // 웹 환경
    // if (kIsWeb) {
    //   removeChromeAccessToken();
    // }
    // // 모바일 환경  
    // else {
    //   await removeAccessToken();
    // }

    Get.offAllNamed('/');
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
                              decoration: BoxDecoration(
                                color: Colors.blue,
                                border: Border.all(
                                    color: Colors.white, width: 2), // 테두리 추가
                              ),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceAround,
                                children: [
                                  Container(
                                    width: 50,
                                    height: 50,
                                    decoration: const BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: Colors.white,
                                    ),
                                    child: ClipOval(
                                      child: Image.asset(
                                        'images/test_profile.png', // 프로필 이미지 경로
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                  ),

                                  // 프로필과 텍스트 사이 여백
                                  // Lv. 과 이름 텍스트
                                  Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        '테스트',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 14,
                                        ),
                                      ),
                                      SizedBox(height: 4),
                                      Text(
                                        'Lv. ' + level.toString(),
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                          Flexible(
                            flex: 1,
                            child: Container(
                              height: 20,
                              color: Colors.purple,
                              child: Row(
                                children: [
                                  Expanded(
                                    child: Container(
                                      margin: const EdgeInsets.symmetric(
                                          horizontal: 5, vertical: 3.5),
                                      decoration: BoxDecoration(
                                        color: Colors.green,
                                        borderRadius:
                                            BorderRadius.circular(10), // 둥근 모서리
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
              image: const AssetImage('images/bird_Omoknoonii.gif'),
              width: 200,
              height: 200,
              fit: BoxFit.contain,
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
        ],
      ),
    );
  }
}
