import 'dart:convert';

import 'package:bird_raise_app/api/api_bag.dart';
import 'package:bird_raise_app/api/api_shop.dart';
import 'package:bird_raise_app/gui_click_pages/shop_page.dart';
import 'package:bird_raise_app/model/gold_model.dart';
import 'package:bird_raise_app/token/chrome_token.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:bird_raise_app/token/mobile_secure_token.dart';
import 'package:provider/provider.dart';

class BagPage extends StatefulWidget {
  const BagPage({super.key});

  @override
  State<BagPage> createState() => _BagPage();
}

class _BagPage extends State<BagPage> with TickerProviderStateMixin {
  String imagepath = 'images/items/apple.png';
  List<String> imagePaths = [];
  List<String> itemNames = [];
  List<String> itemLore = [];
  List<String> itemAmounts = [];
  List<String> itemCode = [];
  int selectedIndex = 0;
  int userGold = 0;
  bool isDataLoaded = false;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeData();
      _fetchUserInfo();
    });
  }

  List<Map<String, String>> bagItems = [];
  Future<void> _initializeData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final items = await fetchBagData(); // List<Map<String, String>>

      setState(() {
        imagePaths = items.map((item) => item['imagePath'] ?? '').toList();
        itemNames = items.map((item) => item['itemName'] ?? '').toList();
        itemLore = items.map((item) => item['itemDescription'] ?? '').toList();
        itemAmounts = items.map((item) => item['amount'] ?? '').toList();
        itemCode = items.map((item) => item['itemCode'] ?? '').toList();

        selectedIndex = 0;
        _isLoading = false;
      });
    } catch (e) {
      print('가방 데이터 로딩 실패: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('가방 아이템을 불러오지 못했습니다.',
                style: TextStyle(fontFamily: 'NaverNanumSquareRound')),
          ),
        );
      }
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _fetchUserInfo() async {
    final userInfo = await loadUserInfo();
    if (userInfo != null) {
      context.read<GoldModel>().updateGold(userInfo['gold']); // 골드만 전역 상태에 반영
    }
  }

  @override
  Widget build(BuildContext context) {
    final goldModel = context.watch<GoldModel>();
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          '가방',
          style: TextStyle(fontFamily: 'NaverNanumSquareRound'),
        ),
        centerTitle: true,
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : Column(
              children: [
                // 선택된 아이템 상세 정보 표시
                Row(
                  children: [
                    Expanded(
                      child: Container(
                        height: MediaQuery.of(context).size.height / 5,
                        color: const Color.fromARGB(255, 145, 238, 207),
                        child: Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              if (imagePaths.isNotEmpty)
                                Stack(
                                  alignment: Alignment.center,
                                  children: [
                                    Container(
                                      width: 80,
                                      height: 80,
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(8),
                                        image: const DecorationImage(
                                          image: AssetImage(
                                              'images/background/shop_item_background.png'),
                                          fit: BoxFit.fill,
                                        ),
                                      ),
                                    ),
                                    Image.asset(
                                      'images/items/${imagePaths[selectedIndex]}',
                                      width: 70,
                                      height: 70,
                                      fit: BoxFit.contain,
                                    ),
                                  ],
                                ),
                              const SizedBox(height: 10),
                              if (itemAmounts.isNotEmpty)
                                Text(
                                  '수량: ${itemAmounts[selectedIndex]}',
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    fontFamily: 'NaverNanumSquareRound',
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    Container(
                      width: MediaQuery.of(context).size.width * 0.4,
                      height: MediaQuery.of(context).size.height / 5,
                      color: const Color.fromARGB(255, 64, 62, 201),
                      child: Column(
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(top: 20.0),
                            child: Text(
                              itemNames.isNotEmpty
                                  ? itemNames[selectedIndex]
                                  : '',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                fontFamily: 'NaverNanumSquareRound',
                              ),
                            ),
                          ),
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text(
                                itemLore.isNotEmpty
                                    ? itemLore[selectedIndex]
                                    : '',
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontFamily: 'NaverNanumSquareRound',
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 3),
                // 그리드 형태의 아이템 목록
                Expanded(
                  child: GridView.builder(
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 5,
                      mainAxisSpacing: 3,
                      childAspectRatio: 1.0,
                    ),
                    itemCount: imagePaths.length,
                    itemBuilder: (context, index) {
                      return GestureDetector(
                        onTap: () {
                          setState(() {
                            selectedIndex = index;
                          });
                        },
                        child: Container(
                          margin: const EdgeInsets.all(2),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Stack(
                            children: [
                              // 아이템 배경
                              Positioned.fill(
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: Image.asset(
                                    'images/background/shop_item_background.png',
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),

                              // 아이템 이미지
                              Center(
                                child: FractionallySizedBox(
                                  widthFactor: 0.9,
                                  heightFactor: 0.9,
                                  child: Image.asset(
                                    'images/items/${imagePaths[index]}',
                                    fit: BoxFit.contain,
                                  ),
                                ),
                              ),
                              Positioned(
                                right: 4,
                                bottom: 4,
                                child: Builder(
                                  builder: (context) {
                                    double screenWidth =
                                        MediaQuery.of(context).size.width;
                                    double fontSize =
                                        screenWidth * 0.03; // 예: 3% 비율
                                    double horizontalPadding =
                                        screenWidth * 0.020; // padding도 비율로!
                                    double verticalPadding =
                                        screenWidth * 0.010; // 세로 패딩도 비율로!

                                    return Container(
                                      padding: EdgeInsets.symmetric(
                                        horizontal: horizontalPadding,
                                        vertical: verticalPadding,
                                      ),
                                      decoration: BoxDecoration(
                                        color: Colors.black54,
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                      child: Text(
                                        itemAmounts[index],
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: fontSize,
                                          fontWeight: FontWeight.bold,
                                          fontFamily: 'NaverNanumSquareRound',
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
                // Footer navigation bar 추가
                const SizedBox(height: 3),
                Container(
                  height: 70,
                  child: Row(
                    children: [
                      Expanded(
                        child: Container(
                          color: Colors.blue[100],
                          child: const Center(
                            child: Text(
                              '도감',
                              style: TextStyle(
                                  fontFamily: 'NaverNanumSquareRound'),
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
                              style: TextStyle(
                                  fontFamily: 'NaverNanumSquareRound'),
                            ),
                          ),
                        ),
                      ),
                      Expanded(
                        child: GestureDetector(
                          onTap: () async {
                            Get.off(() => const ShopPage());
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
                            Get.off(() => const BagPage());
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
              ],
            ),
    );
  }
}
