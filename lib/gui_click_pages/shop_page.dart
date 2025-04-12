import 'dart:convert';

import 'package:bird_raise_app/gui_click_pages/bag_page.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:bird_raise_app/token/chrome_token.dart';
import 'package:http/http.dart' as http;
import 'package:bird_raise_app/api/api_shop.dart';

class ShopPage extends StatefulWidget {
  const ShopPage({super.key});

  @override
  State<ShopPage> createState() => _ShopPage();
}

class _ShopPage extends State<ShopPage> with TickerProviderStateMixin {
  String imagepath = 'images/items/1_apple.png';

  List<String> imagePaths = [];
  List<String> itemNames = [];
  List<String> itemLore = [];
  List<String> itemPrice = [];
  List<String> itemCode = [];

  int selectedIndex = 0;
  int userMoney = 0;
  bool isDataLoaded = false;
  bool _isLoading = true;
  int category = 1; // Default category

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeData();
      _fetchUserMoney();
    });
  }

  Future<void> _initializeData() async {
    setState(() {
      _isLoading = true;
    });

    String requestUrl =
        "http://localhost:8080/api/v1/shop/page?pageNo=0&category=$category";
    final url = Uri.parse(requestUrl);

    String? token = getChromeAccessToken();
    print("발급된 JWT: $token");
    String bearerToken = "Bearer $token";

    try {
      final response = await http.get(
        url,
        headers: {'Authorization': bearerToken},
      );
      print(response.body);

      if (response.statusCode == 200) {
        // 한글 깨짐 발생 시 jsonDecode(response.body)에서 jsonDecode(utf8.decode(response.bodyBytes))으로 변경
        final Map<String, dynamic> jsonResponse = Map<String, dynamic>.from(
            jsonDecode(utf8.decode(response.bodyBytes)));
        final List<dynamic> contentList =
            jsonResponse['content'] as List<dynamic>;

        // Update imagePaths list and rebuild UI
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
  Future<void> _fetchUserMoney() async {
    int money = await loadUserMoney();
    if (money != -1) {
      setState(() {
        userMoney = money;
      });
    }
  }

  // 아이템 구매 핸들러
  Future<void> _handleBuyItem(String itemCode) async {
    int result = await buyItem(itemCode);
    if (result == 1) {
      await _fetchUserMoney();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              "구매 완료!",
              style: TextStyle(fontFamily: 'NaverNanumSquareRound'),
            ),
          ),
        );
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              "구매 실패: 골드가 부족합니다.",
              style: TextStyle(fontFamily: 'NaverNanumSquareRound'),
            ),
          ),
        );
      }
    }
  }

  // 아이템 판매 핸들러
  Future<void> _handleSellItem(String itemCode) async {
    int result = await sellItem(itemCode);
    if (result == 1) {
      await _fetchUserMoney();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              "판매 완료!",
              style: TextStyle(fontFamily: 'NaverNanumSquareRound'),
            ),
          ),
        );
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              "판매 실패: 판매할 아이템이 없습니다.",
              style: TextStyle(fontFamily: 'NaverNanumSquareRound'),
            ),
          ),
        );
      }
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
                        Text(
                          '$userMoney',
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
            Expanded(
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
                                  onTap: () async {
                                    _handleBuyItem(itemCode[selectedIndex]);
                                  },
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 18, vertical: 9),
                                    decoration: BoxDecoration(
                                      color: Colors.blue,
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: const Text(
                                      '구매',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold,
                                        fontFamily: 'NaverNanumSquareRound',
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                GestureDetector(
                                  onTap: () {
                                    _handleSellItem(itemCode[selectedIndex]);
                                  },
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 18, vertical: 9),
                                    decoration: BoxDecoration(
                                      color: Colors.red,
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: const Text(
                                      '판매',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold,
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
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                '${imagePaths[index]}번째 물건입니다.',
                                style: const TextStyle(
                                  fontFamily: 'NaverNanumSquareRound',
                                ),
                              ),
                              duration: const Duration(milliseconds: 250),
                            ),
                          );
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
                          onTap: () {
                            Get.off(() => const ShopPage());
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
                            Get.off(() => const BagPage());
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
