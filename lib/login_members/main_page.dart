import 'dart:convert';
import 'package:bird_raise_app/token/chrome_token.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
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
            const SnackBar(content: Text('API 호출에 실패했습니다.')),
          );
        }
      }
    } catch (e) {
      print('Error: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('서버 연결에 실패했습니다.')),
        );
      }
    }

    if (mounted) {
      Future.delayed(Duration.zero, () {
        print('로그인 성공!');
      });
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
      appBar: AppBar(
        automaticallyImplyLeading: false,
        centerTitle: true, // 제목을 중앙에 배치
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly, // 균등 분배
          children: [
            Expanded(
              // Expanded로 감싸서 비율 유지
              flex: 1,
              child: Container(
                height: 300,
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
              // Expanded로 감싸서 비율 유지
              flex: 1,
              child: Container(
                height: 100,
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
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 10), // 8px 간격 추가
            Expanded(
              // Expanded로 감싸서 비율 유지
              flex: 1,
              child: Container(
                height: 100,
                child: Image.asset(
                  'images/GUI/star_coin_GUI.png',
                  width: 200,
                  height: 100,
                ),
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
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
        ],
      ),
      body: Stack(
        children: [
          const Center(
            child: Text('이곳은 바디 영역입니다.'),
          ),
          Positioned(
            top: 0,
            right: 8,
            child: IconButton(
              iconSize: 50,
              icon: Image.asset(
                'images/post_button.png',
                width: 50,
                height: 50,
              ),
              onPressed: () {
                print('편지 아이콘 클릭');
              },
            ),
          ),
          Positioned(
            top: MediaQuery.of(context).size.height / 2 - 380,
            left: MediaQuery.of(context).size.width / 2 - 250,
            child: Image.asset(
              'images/floor-blue-rug.png',
              width: 500,
              height: 500,
            ),
          ),
          Positioned(
            top: MediaQuery.of(context).size.height / 2 - 320,
            left: MediaQuery.of(context).size.width / 2 - 100,
            child: Gif(
              controller: controller,
              image: const AssetImage('images/bird_Omoknoonii.gif'),
              width: 200,
              height: 200,
            ),
          ),
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
                      child: const Center(child: Text('도감')),
                    ),
                  ),
                  Expanded(
                    child: Container(
                      color: Colors.green[100],
                      child: const Center(child: Text('모험')),
                    ),
                  ),
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const ShopPage(),
                          ),
                        );
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
                      onTap: () {
                        print('가방을 클릭했습니다.');
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
