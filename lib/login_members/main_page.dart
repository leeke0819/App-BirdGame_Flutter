import 'package:flutter/material.dart';
import 'package:gif/gif.dart';

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  _MainPageState createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> with TickerProviderStateMixin {
  late final GifController controller;

  @override
  void initState() {
    super.initState();
    controller = GifController(vsync: this);

    // gif 루프
    controller.repeat(period: Duration(milliseconds: 1300));

    Future.delayed(Duration.zero, () {
      const snackBar = SnackBar(content: Text('로그인 성공!'));
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
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
