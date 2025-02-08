import 'dart:convert';
import 'package:bird_raise_app/token/chrome_token.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:gif/gif.dart';
import 'package:http/http.dart' as http;

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
        const snackBar = SnackBar(content: Text('로그인 성공!'));
        ScaffoldMessenger.of(context).showSnackBar(snackBar);
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
          children: [
            Transform.translate( // 프로필 창 회색 뒷배경
              offset: const Offset(-16, 0),
              child: Stack(
                children: [
                  Container(
                    width: 150,
                    height: 300,
                    color: Colors.grey,
                  ),
                  Positioned( // 프로필 사진 (원)
                    left: 8,
                    top: 127,
                    child: Container(
                      width: 45,
                      height: 45,
                      decoration: const BoxDecoration(
                        color: Colors.yellow,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                  const Positioned( // 닉네임 (나중에 if문으로 몇 글자인지에 따라서 위치 조절. 현재는 한글 6글자 기준.)
                    left: 58, // 중앙(75) + 10px 오른쪽
                    top: 130, // 중앙(150) - 10px 위쪽
                    child: Text(
                      "가나다라마바",
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 16,
                      ),
                    ),
                  ),
                  const Positioned( // 레벨 (나중에 if문으로 몇자리 수의 레벨인지에 따라서 위치 조절. 현재는 3자리 수 기준.)
                    left: 96,
                    top: 150, // 닉네임 위치(130) + 20px(텍스트 높이 + 10px 간격)
                    child: Text(
                      "Lv. 100",
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(
                width: 150,
                height: 100,
                child: Column(
                  children: [
                    Transform.translate(
                      offset: const Offset(-8, 0),
                      child: Stack(
                        alignment: Alignment.centerRight, // Changed to right alignment
                        children: [
                          Image.asset(
                            'images/main_page_Gold_GUI.png',
                            width: 200,
                            height: 100,
                          ),
                          Padding(
                            padding: const EdgeInsets.only(right: 5), // Add padding from right
                            child: Text(
                              '$money',
                              style: const TextStyle(
                                color: Colors.black,
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                )),
            Container(
              width: 130,
              height: 100,
              color: Colors.pink,
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
            left: 0,
            child: Stack(
              children: [
                Container( // 경험치 바 회색 뒷배경
                  width: 150,
                  height: 15,
                  color: Colors.grey,
                ),
                Container( // 경험치 바 녹색 전경
                  width: 140,
                  height: 10,
                  margin: const EdgeInsets.only(left: 5), // 오른쪽으로 5px 이동
                  decoration: BoxDecoration(
                    color: Colors.green,
                    borderRadius: BorderRadius.circular(5),
                  ),
                ),
              ],
            ),
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
            top: MediaQuery.of(context).size.height * 0.5 - 400, // 화면 높이를 기준으로 상대적인 위치 지정
            left: MediaQuery.of(context).size.width * 0.5 - 250, // 화면 너비를 기준으로 상대적인 위치 지정
            child: Container(
              width: MediaQuery.of(context).size.width * 0.8, // 화면 너비에 대한 비율로 크기 지정
              height: MediaQuery.of(context).size.height * 0.8, // 화면 높이에 대한 비율로 크기 지정
              color: const Color.fromRGBO(255, 198, 113, 1),
              child: Stack(
                children: [
                  Positioned(
                    child: Image.asset(
                      'images/floor-blue-rug.png',
                      width: MediaQuery.of(context).size.width * 0.8, // 유동적인 크기
                      height: MediaQuery.of(context).size.height * 0.8, // 유동적인 크기
                    ),
                  ),
                  Positioned(
                    top: MediaQuery.of(context).size.height * 0.24, // 비율을 사용한 위치
                    left: MediaQuery.of(context).size.width * 0.3, // 비율을 사용한 위치
                    child: Gif(
                      controller: controller,
                      image: const AssetImage('images/bird_Omoknoonii.gif'),
                      width: MediaQuery.of(context).size.width * 0.4, // 유동적인 크기
                      height: MediaQuery.of(context).size.height * 0.27, // 유동적인 크기
                    ),
                  ),
                ],
              ),
            ),
          ),
          Positioned( // 보라색 뒷배경
            bottom: 70, // 하단 GUI 높이만큼 띄움
            left: 0,
            right: 0,
            child: Stack(
              children: [
                Container(
                  height: MediaQuery.of(context).size.height / 2 - 170, // 주황색 배경과 하단 GUI 사이 공간
                  color: const Color.fromARGB(255, 145, 97, 173),
                ),
                Positioned(
                  top: 2,
                  left: 2,
                  child: Container( // 먹이 조합 도움말 ( 다홍색 부분 )
                    width: 50,
                    height: 60,
                    color: const Color.fromARGB(255, 255, 69, 69), // 다홍색
                  ),
                ),
                Positioned(
                  top: 80,
                  left: 2,
                  child: Container( // 도구 ( 연분홍색 부분 )
                    width: 50,
                    height: 50,
                    color: const Color.fromARGB(255, 233, 129, 129), // 연분홍색
                  ),
                )
              ],
            ),
          ),
          Positioned( // 하단 gui 뒷배경
            bottom: 0,
            left: 0,
            right: 0,
            child: SizedBox(
              height: 70,
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      color: const Color.fromARGB(255, 130, 199, 255),
                      child: const Center(child: Text('도감')),
                    ),
                  ),
                  Expanded(
                    child: Container(
                      color: const Color.fromARGB(255, 123, 252, 127),
                      child: const Center(child: Text('모험')),
                    ),
                  ),
                  Expanded(
                    child: Container(
                      color: Colors.orange[100],
                      child: const Center(child: Text('상점')),
                    ),
                  ),
                  Expanded(
                    child: Container(
                      color: Colors.purple[100],
                      child: const Center(child: Text('가방')),
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
