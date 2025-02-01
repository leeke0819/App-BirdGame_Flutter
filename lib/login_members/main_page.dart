import 'dart:convert';
import 'package:bird_raise_app/token/all_token.dart';
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

  @override
  Future<void> initState() async {
    super.initState();
    controller = GifController(vsync: this);
    final url = Uri.parse('http://localhost:8080/api/v1/user');
    //String bearerToken = "Bearer" + getAccessToken(); <- 여기에서 크롬(웹)인지 모바일인지 검사를 해줘야함
    // 자세한건 main.dart 54번째 줄부터 63번째 줄까지 있는 if-else문을 보자.
    try{
      final response = await http.post(
        url,
        //headers: {'Authorization': '(여기에 위에서 String(문법 맞는지는 모름)으로 선언한 변수 bearerToken을 넣어야 함)'},
      );

      // if (response.statusCode == 200) {
      //   Map<String, dynamic> responseData = json.decode(response.body); <- if문 지우기
      //   getAccessToken(responseData['accessToken']);//.. 가져와서 api콜 해서 띄워주기
      // }
    } catch (e) {
      // print('Error: $e');
      // ScaffoldMessenger.of(context).showSnackBar(
      //   const SnackBar(content: Text('서버 연결에 실패했습니다.')),
      // );
    }

    // gif 루프
    controller.repeat(period: Duration(milliseconds: 1300));

    Future.delayed(Duration.zero, () {
      const snackBar = SnackBar(content: Text('로그인 성공!'));
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
    });
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
        centerTitle: true, // 제목을 중앙에 배치
        title: Image.asset(
          'images/main_page_Gold_GUI.png',
          width: 400,
          height: 100,
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
            top: MediaQuery.of(context).size.height / 2 - 100,
            left: MediaQuery.of(context).size.width / 2 - 50,
            child: Image.asset(
              'images/free-icon-nuts-5663679.png',
              width: 50,
              height: 50,
            ),
          ),
        ],
      ),
    );
  }
}
