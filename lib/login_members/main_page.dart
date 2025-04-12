import 'dart:convert';
import 'package:bird_raise_app/gui_click_pages/bag_page.dart';
import 'package:bird_raise_app/token/chrome_token.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:gif/gif.dart';
import 'package:http/http.dart' as http;
import '../gui_click_pages/shop_page.dart';

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  _MainPageState createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> with TickerProviderStateMixin {
  final TextEditingController _moneyController = TextEditingController();
  final TextEditingController _nicknameController = TextEditingController();
  late final GifController controller;
  int money = 0;
  String? nickname;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    controller = GifController(vsync: this);

    // 비동기 메서드 실행
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeData();
    });

    // gif 루프
    controller.repeat(period: Duration(milliseconds: 1300));
  }

  Future<void> _initializeData() async {
    final url = Uri.parse('http://localhost:8080/api/v1/user');

    String? token = getChromeAccessToken();
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
        setState(() {
          money = responseData['money'];
          nickname = responseData['nickname'];
          isLoading = false;
        });
      } else {
        print('API 호출 실패 : ${response.statusCode}');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                'API 호출에 실패했습니다.',
                style: TextStyle(fontFamily: 'NaverNanumSquareRound'),
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
              style: TextStyle(fontFamily: 'NaverNanumSquareRound'),
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

  // user money 값만 다시 로딩
  Future<void> _fetchUserMoney() async {
    final url = Uri.parse('http://localhost:8080/api/v1/user');
    String? token = getChromeAccessToken();
    String bearerToken = "Bearer $token";

    try {
      final response = await http.get(
        url,
        headers: {'Authorization': bearerToken},
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        setState(() {
          money = responseData['money'];
        });
      }
    } catch (e) {
      print('돈 가져오기 실패: $e');
    }
  }

  @override
  void dispose() {
    _moneyController.dispose();
    _nicknameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
                              color: Colors.blue,
                              child: const Row(
                                children: [
                                  // Upper content
                                ],
                              ),
                            ),
                          ),
                          Flexible(
                            flex: 1,
                            child: Container(
                              height: 20,
                              color: Colors.green,
                              child: const Row(
                                children: [
                                  // Lower content
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    flex: 1,
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
                              Text(
                                '$money',
                                style: const TextStyle(
                                  color: Colors.black,
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  fontFamily: 'NaverNanumSquareRound',
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    flex: 1,
                    child: SizedBox(
                      height: 100,
                      child: Transform.translate(
                        offset: const Offset(0, -26),
                        child: Image.asset(
                          'images/GUI/star_coin_GUI.png',
                          width: 200,
                          height: 100,
                        ),
                      ),
                    ),
                  ),
                  Transform.translate(
                    offset: const Offset(10, -15),
                    child: IconButton(
                      iconSize: 50,
                      icon: Image.asset(
                        'images/setting_button.png',
                        width: 50,
                        height: 50,
                      ),
                      onPressed: () {
                        print('설정 아이콘 클릭');
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
                        await _fetchUserMoney(); // money 값 갱신
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
                        await _fetchUserMoney(); // money 값 갱신
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
