import 'dart:convert';

import 'package:bird_raise_app/api/api_shop.dart';
import 'package:bird_raise_app/gui_click_pages/shop_page.dart';
import 'package:bird_raise_app/token/chrome_token.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';

class BagPage extends StatefulWidget {
  const BagPage({super.key});

  @override
  State<BagPage> createState() => _BagPage();
}

class _BagPage extends State<BagPage> with TickerProviderStateMixin {
  String imagepath = 'images/items/1_apple.png';
  List<String> imagePaths = [];
  List<String> itemNames = [];
  List<String> itemLore = [];
  List<String> itemAmounts = [];
  List<String> itemCode = [];
  int selectedIndex = 0;
  int userMoney = 0;
  bool isDataLoaded = false;
  bool _isLoading = true;

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

    String requestUrl = "http://localhost:8080/api/v1/bag/page?pageNo=" + "0";
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
        final List<dynamic> jsonResponse =
            jsonDecode(utf8.decode(response.bodyBytes));

        setState(() {
          imagePaths = jsonResponse
              .map((item) => item['itemEntity']['imageRoot'].toString())
              .toList();
          itemNames = jsonResponse
              .map((item) => item['itemEntity']['itemName'].toString())
              .toList();
          itemLore = jsonResponse
              .map((item) => item['itemEntity']['itemDescription'].toString())
              .toList();
          itemAmounts =
              jsonResponse.map((item) => item['amount'].toString()).toList();
          itemCode = jsonResponse
              .map((item) => item['itemEntity']['itemCode'].toString())
              .toList();
          _isLoading = false;
        });
      } else {
        print('API 호출 실패: ${response.statusCode}');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('API 호출에 실패했습니다.')),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('서버 연결에 실패했습니다.')),
        );
      }
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _fetchUserMoney() async {
    int money = await loadUserMoney();
    if (money != -1) {
      setState(() {
        userMoney = money;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('가방'),
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
                                Container(
                                  width: 80,
                                  height: 80,
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    border: Border.all(color: Colors.black),
                                  ),
                                  child: Image.asset(
                                    'images/items/${imagePaths[selectedIndex]}',
                                    fit: BoxFit.contain,
                                  ),
                                ),
                              const SizedBox(height: 10),
                              if (itemAmounts.isNotEmpty)
                                Text(
                                  '수량: ${itemAmounts[selectedIndex]}',
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
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
                        child: Stack(
                          children: [
                            Container(
                              margin: const EdgeInsets.all(2),
                              decoration: BoxDecoration(
                                border: Border.all(
                                  color: selectedIndex == index
                                      ? Colors.blue
                                      : Colors.grey,
                                  width: 2,
                                ),
                              ),
                              child: Image.asset(
                                'images/items/${imagePaths[index]}',
                                fit: BoxFit.cover,
                              ),
                            ),
                            Positioned(
                              right: 2,
                              bottom: 2,
                              child: Container(
                                padding: const EdgeInsets.all(2),
                                color: Colors.black54,
                                child: Text(
                                  itemAmounts[index],
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                            ),
                          ],
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
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const BagPage(),
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
