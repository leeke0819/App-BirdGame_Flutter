import 'package:flutter/material.dart';

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  _MainPageState createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  @override
  void initState() {
    super.initState();
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
          // 1) 설정 아이콘 (AppBar 오른쪽 끝, 50x50)
          IconButton(
            iconSize: 50, // IconButton 자체의 사이즈
            icon: Image.asset(
              'images/free-icon-settings-6704985.png',
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
          // 바디의 주된 내용(원하는 위젯)
          const Center(
            child: Text('이곳은 바디 영역입니다.'),
          ),

          // 2) 편지 아이콘 (AppBar 아래, 설정 아이콘 바로 밑 위치)
          Positioned(
            top: 0,
            right: 8,
            child: IconButton(
              iconSize: 50,
              icon: Image.asset(
                'images/free-icon-love-letter-5573177.png',
                width: 50,
                height: 50,
              ),
              onPressed: () {
                print('편지 아이콘 클릭');
              },
            ),
          ),

          // 3) 흰색 러그 이미지 (새 이미지 뒤에 배치)
          Positioned(
            top: MediaQuery.of(context).size.height / 2 - 380, // 새 이미지 아래에 배치
            left: MediaQuery.of(context).size.width / 2 - 250, // 화면 중앙에 배치
            child: Image.asset(
              'images/white_rug.png',
              width: 500,
              height: 500,
            ),
          ),
          // 4) 새 이미지 (위에 배치될 이미지)
          Positioned(
            top: MediaQuery.of(context).size.height / 2 -
                320, // 화면 가운데에서 50픽셀 아래
            left: MediaQuery.of(context).size.width / 2 - 100, // 화면 가운데에서 수평 중앙
            child: Image.asset(
              'images/free-icon-bird-789479.png',
              width: 200,
              height: 200,
            ),
          ),

          // 4) 견과류 이미지 (위에 배치될 이미지)
          Positioned(
            top: MediaQuery.of(context).size.height / 2 -
                100, // 화면 가운데에서 50픽셀 아래
            left: MediaQuery.of(context).size.width / 2 - 50, // 화면 가운데에서 수평 중앙
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
