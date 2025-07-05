import 'dart:convert';

import 'package:bird_raise_app/config/env_config.dart';
import 'package:bird_raise_app/gui_click_pages/bag_page.dart';
import 'package:bird_raise_app/model/gold_model.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:bird_raise_app/token/chrome_token.dart';
import 'package:http/http.dart' as http;
import 'package:bird_raise_app/api/api_shop.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:bird_raise_app/token/mobile_secure_token.dart';
import 'package:provider/provider.dart';
import 'package:bird_raise_app/model/shop_model.dart';


class ShopPage extends StatefulWidget {
  const ShopPage({super.key});

  @override
  State<ShopPage> createState() => _ShopPage();
}

class _ShopPage extends State<ShopPage> with TickerProviderStateMixin {
  String imagepath = 'images/items/apple.png';

  List<String> imagePaths = [];
  List<String> itemNames = [];
  List<String> itemLore = [];
  List<String> itemPrice = [];
  List<String> itemCode = [];

  int selectedIndex = 0;
  int starCoin = 0;
  bool _isLoading = true;
  int category = 1; // Default category
  late ShopModel shopModel;

  @override
  void initState() {
    super.initState();
    shopModel = ShopModel();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeData();
      _fetchUserInfo();
    });
  }

  @override
  void dispose() {
    shopModel.dispose();
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
          _isLoading = false;
        });
      } else {
        print('API 호출 실패: ${response.statusCode}');
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
    final gold = goldModel.gold;
    return Scaffold(
      appBar: AppBar(
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
                                  onTap: () {
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
          : Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Stack(
                        children: [
                          Container(
                            height: MediaQuery.of(context).size.height / 5,
                            decoration: const BoxDecoration(
                              color: Color.fromARGB(255, 145, 238, 207),
                            ),
                            child: Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.only(bottom: 60),
                                    child: Container(
                                      width: MediaQuery.of(context).size.width >
                                              600
                                          ? (MediaQuery.of(context).size.width *
                                                  0.6 /
                                                  5)
                                              .clamp(50, 90) // 크기를 50~90 사이로 제한
                                          : (MediaQuery.of(context).size.width *
                                                  0.7 /
                                                  5)
                                              .clamp(40, 70),
                                      height: MediaQuery.of(context)
                                                  .size
                                                  .width >
                                              600
                                          ? (MediaQuery.of(context).size.width *
                                                  0.6 /
                                                  5)
                                              .clamp(50, 90)
                                          : (MediaQuery.of(context).size.width *
                                                  0.7 /
                                                  5)
                                              .clamp(40, 70),
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(8),
                                        image: const DecorationImage(
                                          image: AssetImage(
                                              'images/background/shop_item_background.png'),
                                          fit: BoxFit.contain,
                                        ),
                                      ),
                                      clipBehavior: Clip.hardEdge,
                                      child: imagePaths.isNotEmpty
                                          ? Padding(
                                              padding: const EdgeInsets.all(
                                                  4.0), // 숫자를 늘리면 이미지가 작아짐
                                              child: Image.asset(
                                                'images/items/${imagePaths[selectedIndex]}',
                                                fit: BoxFit.contain,
                                              ),
                                            )
                                          : Container(),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          Positioned(
                            left: 0,
                            right: 0,
                            bottom: 20,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 30, vertical: 8),
                                  decoration: BoxDecoration(
                                    color: Colors.grey[300],
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    itemPrice[selectedIndex],
                                    textAlign: TextAlign.center,
                                    style: const TextStyle(
                                      color: Colors.black,
                                      fontSize: 14,
                                      fontWeight: FontWeight.normal,
                                      fontFamily: 'NaverNanumSquareRound',
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                GestureDetector(
                                  onTap: () {
                                    shopModel.showQuantityDialog(
                                      context,
                                      itemCode[selectedIndex],
                                      true,
                                      _handleBuyItem,
                                      _handleSellItem,
                                    );
                                  },
                                  child: Stack(
                                    alignment: Alignment.center,
                                    children: [
                                      SizedBox(
                                        width:
                                            MediaQuery.of(context).size.width *
                                                0.12,
                                        height:
                                            MediaQuery.of(context).size.width *
                                                0.12,
                                        child: Image.asset(
                                          'images/GUI/buy_button_GUI.png',
                                          fit: BoxFit.contain,
                                        ),
                                      ),
                                      const Text(
                                        '구매',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 14,
                                          fontWeight: FontWeight.bold,
                                          fontFamily: 'NaverNanumSquareRound',
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 8),
                                GestureDetector(
                                  onTap: () {
                                    shopModel.showQuantityDialog(
                                      context,
                                      itemCode[selectedIndex],
                                      false,
                                      _handleBuyItem,
                                      _handleSellItem,
                                    );
                                  },
                                  child: Stack(
                                    alignment: Alignment.center,
                                    children: [
                                      SizedBox(
                                        width:
                                            MediaQuery.of(context).size.width *
                                                0.12,
                                        height:
                                            MediaQuery.of(context).size.width *
                                                0.12,
                                        child: Image.asset(
                                          'images/GUI/sell_button_GUI.png',
                                          fit: BoxFit.contain,
                                        ),
                                      ),
                                      const Text(
                                        '판매',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 14,
                                          fontWeight: FontWeight.bold,
                                          fontFamily: 'NaverNanumSquareRound',
                                        ),
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
                    Container(
                      width: MediaQuery.of(context).size.width * 0.4,
                      height: MediaQuery.of(context).size.height / 5,
                      decoration: const BoxDecoration(
                        color: Color.fromARGB(255, 64, 62, 201),
                      ),
                      child: Column(
                        children: [
                          Padding(
                            padding: EdgeInsets.only(top: 20.0),
                            child: Center(
                              child: Text(
                                itemNames[selectedIndex],
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  fontFamily: 'NaverNanumSquareRound',
                                ),
                              ),
                            ),
                          ),
                          Expanded(
                            child: Center(
                              child: Padding(
                                padding: EdgeInsets.all(8.0),
                                child: Text(
                                  itemLore[selectedIndex],
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontFamily: 'NaverNanumSquareRound',
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () => _handleCategoryChange(1),
                        child: Container(
                          height: 50,
                          decoration: BoxDecoration(
                            color:
                                category == 1 ? Colors.blue : Colors.blue[100]!,
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
                                color:
                                    category == 1 ? Colors.white : Colors.black,
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
                        onTap: () => _handleCategoryChange(2),
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
                              '새·알',
                              style: TextStyle(
                                color:
                                    category == 2 ? Colors.white : Colors.black,
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
                Expanded(
                  child: GridView.builder(
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 5,
                      mainAxisSpacing: 3,
                      childAspectRatio: 1.0,
                    ),
                    itemCount: imagePaths.isEmpty ? 30 : imagePaths.length,
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
                                  padding: const EdgeInsets.all(6.0),
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
                        child: Container(
                          color: Colors.blue[100],
                          child: const Center(
                            child: Text(
                              '도감',
                              style: TextStyle(
                                fontFamily: 'NaverNanumSquareRound',
                              ),
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
                                fontFamily: 'NaverNanumSquareRound',
                              ),
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
