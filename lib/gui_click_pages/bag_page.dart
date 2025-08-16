import 'dart:convert';
import 'dart:async';

import 'package:bird_raise_app/api/api_bag.dart';
import 'package:bird_raise_app/api/api_bird.dart';
import 'package:bird_raise_app/api/api_shop.dart';
import 'package:bird_raise_app/gui_click_pages/adventure_page.dart';
import 'package:bird_raise_app/gui_click_pages/book_page.dart';
import 'package:bird_raise_app/gui_click_pages/shop_page.dart';
import 'package:bird_raise_app/main_page.dart';
import 'package:bird_raise_app/model/bag_model.dart';
import 'package:bird_raise_app/model/gold_model.dart';
import 'package:bird_raise_app/model/new_item_model.dart';
import 'package:bird_raise_app/token/chrome_token.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:bird_raise_app/token/mobile_secure_token.dart';
import 'package:provider/provider.dart';
import 'package:audioplayers/audioplayers.dart';

class BagPage extends StatefulWidget {
  const BagPage({super.key});

  @override
  State<BagPage> createState() => _BagPage();
}

class _BagPage extends State<BagPage> with TickerProviderStateMixin {
  late AudioPlayer buttonClickPlayer;
  late AudioPlayer errorSoundPlayer;
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
    buttonClickPlayer = AudioPlayer();
    errorSoundPlayer = AudioPlayer();
    
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeData();
      _fetchUserInfo();
      // 새 아이템 목록 로드
      context.read<NewItemModel>().loadNewItems();
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
        _playErrorSound();
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

  // 버튼 클릭 효과음 재생 (1초만 재생)
  Future<void> _playButtonClick() async {
    try {
      await buttonClickPlayer.play(AssetSource('sounds/button_click.wav'));
      await buttonClickPlayer.setVolume(0.5);
      
      // 1초 후에 오디오 중지
      Timer(const Duration(seconds: 1), () {
        if (buttonClickPlayer.state == PlayerState.playing) {
          buttonClickPlayer.stop();
        }
      });
    } catch (e) {
      print('버튼 클릭 효과음 재생 실패: $e');
    }
  }

  // 에러 효과음 재생
  Future<void> _playErrorSound() async {
    try {
      await errorSoundPlayer.play(AssetSource('sounds/error_or_ fail_sound.wav'));
      await errorSoundPlayer.setVolume(0.5);
    } catch (e) {
      print('에러 효과음 재생 실패: $e');
    }
  }

  Future<void> _fetchUserInfo() async {
    final userInfo = await loadUserInfo();
    if (userInfo != null) {
      context.read<GoldModel>().updateGold(userInfo['gold']); // 골드만 전역 상태에 반영
    }
  }

  void _handleUseItem(String itemCode) async {
    print("$itemCode 사용 시도");
    final response = await ApiBird.feed(itemCode);
    if (response != null) {
      print("아이템 사용 성공");
      // 아이템 사용 후 가방 데이터 새로고침
      _initializeData();
      // 메인 페이지 새로고침을 위한 이벤트 발생
      Get.find<BagModel>().notifyListeners();
    } else {
      print("아이템 사용 실패");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('아이템 사용에 실패했습니다. 잠시 후 다시 시도해주세요.'),
            duration: Duration(seconds: 2),
          ),
        );
        // 실패 시에도 가방 데이터 새로고침
        _initializeData();
      }
    }
  }

  @override
  void dispose() {
    buttonClickPlayer.dispose();
    errorSoundPlayer.dispose();
    super.dispose();
  }

  Widget build(BuildContext context) {
    final goldModel = context.watch<GoldModel>();
    final newItemModel = context.watch<NewItemModel>();
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () async {
            await _playButtonClick();
            Get.off(() => const MainPage());
          },
        ),
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
          : Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.blue[100]!,
                    Colors.blue[200]!,
                  ],
                ),
              ),
              child: Column(
                children: [
                  // 선택된 아이템 상세 정보 표시
                  Container(
                    margin: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.9),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.blue[300]!, width: 2),
                    ),
                    child: Column(
                      children: [
                        // 제목
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          decoration: BoxDecoration(
                            color: Colors.blue[300],
                            borderRadius: const BorderRadius.only(
                              topLeft: Radius.circular(10),
                              topRight: Radius.circular(10),
                            ),
                          ),
                          child: const Text(
                            '선택된 아이템',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontFamily: 'NaverNanumSquareRound',
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              fontSize: 16,
                            ),
                          ),
                        ),
                        // 아이템 정보
                        Padding(
                          padding: const EdgeInsets.all(16),
                          child: Row(
                            children: [
                              // 선택된 아이템 이미지
                              Container(
                                width: 80,
                                height: 80,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(8),
                                  image: const DecorationImage(
                                    image: AssetImage('images/background/shop_item_background.png'),
                                    fit: BoxFit.cover,
                                  ),
                                ),
                                child: imagePaths.isNotEmpty
                                    ? Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Image.asset(
                                          'images/items/${imagePaths[selectedIndex]}',
                                          fit: BoxFit.contain,
                                        ),
                                      )
                                    : null,
                              ),
                              const SizedBox(width: 16),
                              // 아이템 정보
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      itemNames.isNotEmpty ? itemNames[selectedIndex] : '',
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        fontFamily: 'NaverNanumSquareRound',
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      '수량: ${itemAmounts.isNotEmpty ? itemAmounts[selectedIndex] : '0'}',
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: Colors.grey[600],
                                        fontFamily: 'NaverNanumSquareRound',
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      itemLore.isNotEmpty ? itemLore[selectedIndex] : '',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.grey[500],
                                        fontFamily: 'NaverNanumSquareRound',
                                      ),
                                      maxLines: 3,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  // 그리드 형태의 아이템 목록 또는 빈 가방 메시지
                  Expanded(
                    child: imagePaths.isEmpty
                        ? const Center(
                            child: Text(
                              '가방에 아이템이 없습니다 ;ㅇ;',
                              style: TextStyle(
                                color: Colors.grey,
                                fontSize: 18,
                                fontFamily: 'NaverNanumSquareRound',
                              ),
                            ),
                          )
                        : GridView.builder(
                            padding: const EdgeInsets.all(16),
                            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 5,
                              mainAxisSpacing: 4,
                              crossAxisSpacing: 4,
                              childAspectRatio: 1.0,
                            ),
                            itemCount: imagePaths.length,
                            itemBuilder: (context, index) {
                              return GestureDetector(
                                onTap: () async {
                                  await _playButtonClick();
                                  setState(() {
                                    selectedIndex = index;
                                  });
                                  // 아이템을 클릭했을 때 새 아이템 표시 제거
                                  final currentItemCode = itemCode[index];
                                  if (newItemModel.isNewItem(currentItemCode)) {
                                    newItemModel.removeNewItem(currentItemCode);
                                  }
                                },
                                child: Container(
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(
                                      color: selectedIndex == index 
                                          ? Colors.blue 
                                          : Colors.grey[300]!,
                                      width: selectedIndex == index ? 2 : 1,
                                    ),
                                    image: const DecorationImage(
                                      image: AssetImage('images/background/shop_item_background.png'),
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                  child: Stack(
                                    children: [
                                      Center(
                                        child: Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: Image.asset(
                                            'images/items/${imagePaths[index]}',
                                            fit: BoxFit.contain,
                                          ),
                                        ),
                                      ),
                                      // 수량 표시
                                      Positioned(
                                        bottom: 4,
                                        right: 4,
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 4,
                                            vertical: 2,
                                          ),
                                          decoration: BoxDecoration(
                                            color: Colors.black54,
                                            borderRadius: BorderRadius.circular(4),
                                          ),
                                          child: Text(
                                            itemAmounts[index],
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontSize: 10,
                                              fontWeight: FontWeight.bold,
                                              fontFamily: 'NaverNanumSquareRound',
                                            ),
                                          ),
                                        ),
                                      ),
                                      // 새 아이템 표시 (모서리 둥근 빨간 사각형에 노란색 NEW)
                                      if (newItemModel.isNewItem(itemCode[index]))
                                        Positioned(
                                          top: 4,
                                          left: 4,
                                          child: Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                                            decoration: BoxDecoration(
                                              color: Colors.red,
                                              borderRadius: BorderRadius.circular(6),
                                              border: Border.all(color: Colors.white, width: 1),
                                            ),
                                            child: const Text(
                                              'NEW',
                                              style: TextStyle(
                                                color: Colors.yellow,
                                                fontSize: 8,
                                                fontWeight: FontWeight.bold,
                                                fontFamily: 'NaverNanumSquareRound',
                                              ),
                                            ),
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
                          child: GestureDetector(
                            onTap: () async {
                              await Get.off(() => const BookPage());
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
                                FractionallySizedBox(
                                  widthFactor: 0.90,
                                  heightFactor: 0.90,
                                  child: Image.asset(
                                    'images/GUI/book_GUI.png',
                                    fit: BoxFit.contain,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        Expanded(
                          child: GestureDetector(
                            onTap: () async {
                              await Get.off(() => const AdventurePage());
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
                                FractionallySizedBox(
                                  widthFactor: 0.90,
                                  heightFactor: 0.90,
                                  child: Image.asset(
                                    'images/GUI/adventure_GUI.png',
                                    fit: BoxFit.contain,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        Expanded(
                          child: GestureDetector(
                            onTap: () async {
                              await _playButtonClick();
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
                                FractionallySizedBox(
                                  widthFactor: 0.90,
                                  heightFactor: 0.90,
                                  child: Image.asset(
                                    'images/GUI/shop_GUI.png',
                                    fit: BoxFit.contain,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        Expanded(
                          child: GestureDetector(
                            onTap: () async {
                              await _playButtonClick();
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
                                Stack(
                                  alignment: Alignment.center,
                                  children: [
                                    FractionallySizedBox(
                                      widthFactor: 0.90,
                                      heightFactor: 0.90,
                                      child: Image.asset(
                                        'images/GUI/bag_GUI.png',
                                        fit: BoxFit.contain,
                                      ),
                                    ),
                                    // 새 아이템이 있을 때 표시 (bag_GUI.png 기준으로 위치)
                                    if (newItemModel.newItems.isNotEmpty)
                                      Positioned(
                                        top: 4,
                                        left: 4,
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                          decoration: BoxDecoration(
                                            color: Colors.red,
                                            borderRadius: BorderRadius.circular(8),
                                            border: Border.all(color: Colors.white, width: 1),
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
                ],
              ),
            ),
    );
  }
}
