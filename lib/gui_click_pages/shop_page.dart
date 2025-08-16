import 'dart:convert';
import 'dart:async';

import 'package:bird_raise_app/config/env_config.dart';
import 'package:bird_raise_app/gui_click_pages/bag_page.dart';
import 'package:bird_raise_app/gui_click_pages/book_page.dart';
import 'package:bird_raise_app/gui_click_pages/adventure_page.dart';
import 'package:bird_raise_app/main_page.dart';
import 'package:bird_raise_app/model/gold_model.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:bird_raise_app/token/chrome_token.dart';
import 'package:http/http.dart' as http;
import 'package:bird_raise_app/api/api_shop.dart';
import 'package:bird_raise_app/api/api_bag.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:bird_raise_app/token/mobile_secure_token.dart';
import 'package:provider/provider.dart';
import 'package:bird_raise_app/model/shop_model.dart';
import 'package:bird_raise_app/model/new_item_model.dart';
import 'package:audioplayers/audioplayers.dart';

class ShopPage extends StatefulWidget {
  const ShopPage({super.key});

  @override
  State<ShopPage> createState() => _ShopPage();
}

class _ShopPage extends State<ShopPage> with TickerProviderStateMixin {
  late AudioPlayer buttonClickPlayer;
  late AudioPlayer errorSoundPlayer;
  String imagepath = 'images/items/apple.png';

  List<String> imagePaths = [];
  List<String> itemNames = [];
  List<String> itemLore = [];
  List<String> itemPrice = [];
  List<String> itemCode = [];
  List<String> itemFeed = [];
  List<String> itemThirst = [];

  int selectedIndex = 0;
  int starCoin = 0;
  bool _isLoading = true;
  int category = 1; // Default category
  late ShopModel shopModel;

  @override
  void initState() {
    super.initState();
    shopModel = ShopModel();
    buttonClickPlayer = AudioPlayer();
    errorSoundPlayer = AudioPlayer();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeData();
      _fetchUserInfo();
    });
  }

  @override
  void dispose() {
    shopModel.dispose();
    buttonClickPlayer.dispose();
    errorSoundPlayer.dispose();
    super.dispose();
  }

  Future<void> _initializeData() async {
    setState(() {
      _isLoading = true;
    });

    String requestUrl =
        "${EnvConfig.apiUrl}/shop/page?pageNo=0&category=$category";
    final url = Uri.parse(requestUrl);

    String? token;
    if (kIsWeb) {
      token = getChromeAccessToken();
    } else {
      token = await getAccessToken(); //1초짜리 print문
    }
    print("발급된 JWT: $token");
    String bearerToken = "Bearer $token";

    try {
      final response = await http.get(
        url,
        headers: {'Authorization': bearerToken},
      );
      print(response.body);

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonResponse = Map<String, dynamic>.from(
            jsonDecode(utf8.decode(response.bodyBytes)));
        final List<dynamic> contentList =
            jsonResponse['content'] as List<dynamic>;

        setState(() {
          imagePaths =
              contentList.map((item) => item['imageRoot'].toString()).toList();
          itemNames =
              contentList.map((item) => item['itemName'].toString()).toList();
          itemLore = contentList
              .map((item) => item['itemDescription'].toString())
              .toList();
          itemPrice =
              contentList.map((item) => item['price'].toString()).toList();
          itemCode =
              contentList.map((item) => item['itemCode'].toString()).toList();
          itemFeed =
              contentList.map((item) => item['feed'].toString()).toList();
          itemThirst =
              contentList.map((item) => item['thirst'].toString()).toList();
          _isLoading = false;
        });
      } else {
        print('API 호출 실패: ${response.statusCode}');
        if (mounted) {
          _playErrorSound();
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
        _playErrorSound();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              '서버 연결에 실패했습니다.',
              style: TextStyle(fontFamily: 'NaverNanumSquareRound'),
            ),
          ),
        );
      }
      setState(() {
        _isLoading = false;
      });
    }
  }

  // API에서 사용자 돈 가져오기
  Future<void> _fetchUserInfo() async {
    final userInfo = await loadUserInfo();
    if (userInfo != null) {
      setState(() {
        userGold = userInfo['gold'];
        starCoin = userInfo['starCoin'];
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
      await errorSoundPlayer
          .play(AssetSource('sounds/error_or_ fail_sound.wav'));
      await errorSoundPlayer.setVolume(0.5);
    } catch (e) {
      print('에러 효과음 재생 실패: $e');
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

  Future<void> _handleBuyItem(String itemCode, int quantity) async {
    int result = await buyItem(itemCode, context, quantity);
    if (result == 1) {
      // 구매 성공 후 잠시 기다린 다음 가방 데이터 확인
      await Future.delayed(Duration(milliseconds: 500));

      try {
        final bagItems = await fetchBagData();
        print('가방 데이터 확인: $bagItems');
        print('구매한 아이템 코드: $itemCode');

        // 가방에서 해당 아이템의 수량 확인
        var existingItems =
            bagItems.where((item) => item['itemCode'] == itemCode).toList();

        if (existingItems.isNotEmpty) {
          var existingItem = existingItems.first;
          // amount가 String으로 반환되므로 안전하게 변환
          int currentAmount = 0;
          if (existingItem['amount'] != null) {
            if (existingItem['amount'] is String) {
              currentAmount =
                  int.tryParse(existingItem['amount'] as String) ?? 0;
            } else if (existingItem['amount'] is int) {
              currentAmount = existingItem['amount'] as int;
            }
          }
          print('가방에 있는 아이템 수량: $currentAmount');

          // 수량이 1개 이하일 때만 NEW 표시 (새로 구매한 것으로 간주)
          if (currentAmount <= 1) {
            print('수량이 1개 이하이므로 NEW 표시 추가: $itemCode');
            context.read<NewItemModel>().addNewItem(itemCode);
          } else {
            print('수량이 2개 이상이므로 NEW 표시하지 않음: $itemCode');
          }
        } else {
          print('가방에 없는 아이템이므로 NEW 표시 추가: $itemCode');
          context.read<NewItemModel>().addNewItem(itemCode);
        }
      } catch (e) {
        print('가방 데이터 확인 실패: $e');
        // 확인 실패 시 안전하게 NEW 표시
        print('확인 실패로 인해 NEW 표시 추가: $itemCode');
        context.read<NewItemModel>().addNewItem(itemCode);
      }

      shopModel.showCenterToast(
        "구매 완료!",
        bgColor: const Color(0xFF4CAF50),
      );
    } else {
      shopModel.showCenterToast(
        "구매 실패: 골드가 부족합니다.",
        bgColor: const Color(0xFFE53935),
        textColor: Colors.white,
      );
    }
  }

  Future<void> _handleSellItem(String itemCode, int quantity) async {
    int result = await sellItem(itemCode, context, quantity);
    if (result == 1) {
      shopModel.showCenterToast(
        "판매 완료!",
        bgColor: const Color(0xFF4CAF50),
      );
    } else {
      shopModel.showCenterToast(
        "판매 실패: 판매할 아이템이 없습니다.",
        bgColor: const Color(0xFFE53935),
        textColor: Colors.white,
      );
    }
  }

  // 카테고리 변경 핸들러
  Future<void> _handleCategoryChange(int newCategory) async {
    // 같은 카테고리를 클릭했을 때는 API 호출하지 않음
    if (category == newCategory) return;

    setState(() {
      category = newCategory;
    });
    await _initializeData();
  }

  @override
  Widget build(BuildContext context) {
    final goldModel = context.watch<GoldModel>();
    final newItemModel = context.watch<NewItemModel>();
    final gold = goldModel.gold;
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
        centerTitle: true,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Expanded(
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
                        Positioned(
                          child: Container(
                            width: 200,
                            height: 100,
                            padding: const EdgeInsets.symmetric(horizontal: 0),
                            child: Row(
                              children: [
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Align(
                                    alignment: Alignment.centerRight,
                                    child: FittedBox(
                                      fit: BoxFit.scaleDown,
                                      child: Text(
                                        formatKoreanNumber(gold),
                                        style: const TextStyle(
                                          color: Colors.black,
                                          fontSize: 22,
                                          fontWeight: FontWeight.bold,
                                          fontFamily: 'NaverNanumSquareRound',
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 6),
                                GestureDetector(
                                  onTap: () async {
                                    await _playButtonClick();
                                    print('골드 충전 버튼 클릭');
                                  },
                                  child: Image.asset(
                                    'images/GUI/gold_plus_button_GUI.png',
                                    width: 32,
                                    height: 32,
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
            SizedBox(width: MediaQuery.of(context).size.width * 0.01),
            Expanded(
              flex: 1,
              child: Transform.translate(
                offset: const Offset(0, 0),
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
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 0),
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
                                            fontFamily: 'NaverNanumSquareRound',
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
                                      width: 32,
                                      height: 32,
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
          ],
        ),
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
                    Colors.orange[100]!,
                    Colors.orange[200]!,
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
                      border: Border.all(color: Colors.orange[300]!, width: 2),
                    ),
                    child: Column(
                      children: [
                        // 제목
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          decoration: BoxDecoration(
                            color: Colors.orange[300],
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
                                    image: AssetImage(
                                        'images/background/shop_item_background.png'),
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
                                      itemNames.isNotEmpty
                                          ? itemNames[selectedIndex]
                                          : '',
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        fontFamily: 'NaverNanumSquareRound',
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Row(
                                      children: [
                                        Text(
                                          '가격: ${itemPrice.isNotEmpty ? itemPrice[selectedIndex] : '0'}',
                                          style: TextStyle(
                                            fontSize: 14,
                                            color: Colors.grey[600],
                                            fontFamily: 'NaverNanumSquareRound',
                                          ),
                                        ),
                                        const SizedBox(width: 2),
                                        // 골드 이미지를 살짝 위로 올리기 위해 Transform 사용
                                        Transform.translate(
                                          offset: const Offset(0, -1),
                                          child: Image.asset(
                                            'images/GUI/gold.png',
                                            width: 16,
                                            height: 16,
                                            fit: BoxFit.contain,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      itemLore.isNotEmpty
                                          ? itemLore[selectedIndex]
                                          : '',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.grey[500],
                                        fontFamily: 'NaverNanumSquareRound',
                                      ),
                                      maxLines: 3,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      '배고픔: +${itemFeed.isNotEmpty ? itemFeed[selectedIndex] : '0'} , 목마름: +${itemThirst.isNotEmpty ? itemThirst[selectedIndex] : '0'}',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.grey[500],
                                        fontFamily: 'NaverNanumSquareRound',
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              // 구매/판매 버튼
                              Column(
                                children: [
                                  GestureDetector(
                                    onTap: () async {
                                      await _playButtonClick();
                                      shopModel.showQuantityDialog(
                                        context,
                                        itemCode[selectedIndex],
                                        true,
                                        _handleBuyItem,
                                        _handleSellItem,
                                      );
                                    },
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 16, vertical: 8),
                                      decoration: BoxDecoration(
                                        color: Colors.green,
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: const Text(
                                        '구매',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                          fontFamily: 'NaverNanumSquareRound',
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  GestureDetector(
                                    onTap: () async {
                                      await _playButtonClick();
                                      shopModel.showQuantityDialog(
                                        context,
                                        itemCode[selectedIndex],
                                        false,
                                        _handleBuyItem,
                                        _handleSellItem,
                                      );
                                    },
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 16, vertical: 8),
                                      decoration: BoxDecoration(
                                        color: Colors.red,
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: const Text(
                                        '판매',
                                        style: TextStyle(
                                          color: Colors.white,
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
                      ],
                    ),
                  ),
                  // 카테고리 선택 버튼
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.9),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.orange[300]!, width: 2),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Row(
                        children: [
                          Expanded(
                            child: GestureDetector(
                              onTap: () async {
                                await _playButtonClick();
                                _handleCategoryChange(1);
                              },
                              child: Container(
                                height: 50,
                                decoration: BoxDecoration(
                                  color: category == 1
                                      ? Colors.blue
                                      : Colors.blue[100]!,
                                  border: Border.all(
                                    color: category == 1
                                        ? Colors.blue[700]!
                                        : Colors.blue[300]!,
                                    width: 2,
                                  ),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Center(
                                  child: Text(
                                    '재료',
                                    style: TextStyle(
                                      color: category == 1
                                          ? Colors.white
                                          : Colors.black,
                                      fontWeight: category == 1
                                          ? FontWeight.bold
                                          : FontWeight.normal,
                                      fontFamily: 'NaverNanumSquareRound',
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: GestureDetector(
                              onTap: () async {
                              await _playButtonClick();
                              _handleCategoryChange(2);
                            },
                              child: Container(
                                height: 50,
                                decoration: BoxDecoration(
                                  color: category == 2
                                      ? Colors.green
                                      : Colors.green[100]!,
                                  border: Border.all(
                                    color: category == 2
                                        ? Colors.green[700]!
                                        : Colors.green[300]!,
                                    width: 2,
                                  ),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Center(
                                  child: Text(
                                    '새알',
                                    style: TextStyle(
                                      color: category == 2
                                          ? Colors.white
                                          : Colors.black,
                                      fontWeight: category == 2
                                          ? FontWeight.bold
                                          : FontWeight.normal,
                                      fontFamily: 'NaverNanumSquareRound',
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  // 아이템 그리드
                  Expanded(
                    child: GridView.builder(
                      padding: const EdgeInsets.all(16),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 5,
                        mainAxisSpacing: 4,
                        crossAxisSpacing: 4,
                        childAspectRatio: 1.0,
                      ),
                      itemCount: imagePaths.isEmpty ? 30 : imagePaths.length,
                      itemBuilder: (context, index) {
                        return GestureDetector(
                          onTap: () async {
                            await _playButtonClick();
                            setState(() {
                              selectedIndex = index;
                            });
                          },
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: selectedIndex == index
                                    ? Colors.orange
                                    : Colors.grey[300]!,
                                width: selectedIndex == index ? 2 : 1,
                              ),
                              image: imagePaths.isNotEmpty
                                  ? const DecorationImage(
                                      image: AssetImage(
                                          'images/background/shop_item_background.png'),
                                      fit: BoxFit.cover,
                                    )
                                  : null,
                            ),
                            child: imagePaths.isEmpty
                                ? Container(
                                    decoration: BoxDecoration(
                                      color: Color.fromARGB(
                                        255,
                                        (index * 37) % 255,
                                        (index * 73) % 255,
                                        (index * 127) % 255,
                                      ),
                                    ),
                                  )
                                : Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Image.asset(
                                      'images/items/${imagePaths[index]}',
                                      fit: BoxFit.contain,
                                    ),
                                  ),
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 3),
                  Container(
                    height: 70,
                    child: Row(
                      children: [
                        Expanded(
                          child: GestureDetector(
                            onTap: () async {
                              await _playButtonClick();
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
                              await _playButtonClick();
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
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 6, vertical: 2),
                                          decoration: BoxDecoration(
                                            color: Colors.red,
                                            borderRadius:
                                                BorderRadius.circular(8),
                                            border: Border.all(
                                                color: Colors.white, width: 1),
                                          ),
                                          child: const Text(
                                            'NEW',
                                            style: TextStyle(
                                              color: Colors.yellow,
                                              fontSize: 10,
                                              fontWeight: FontWeight.bold,
                                              fontFamily:
                                                  'NaverNanumSquareRound',
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
