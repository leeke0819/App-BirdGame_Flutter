import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:bird_raise_app/token/chrome_token.dart';
import 'package:http/http.dart' as http;

class ShopPage extends StatefulWidget {
  const ShopPage({super.key});

  @override
  State<ShopPage> createState() => _ShopPage();
}

class _ShopPage extends State<ShopPage> {
  String imagepath = 'images/items/1_apple.png';
  // Add list to store image paths
  List<String> imagePaths = [];
  List<String> itemNames = [];
  List<String> itemLore = [];
  List<String> itemPrice = [];
  // Selected index for displaying image
  int selectedIndex = 0;

  @override
  void initState() {
    super.initState();

    // 비동기 메서드 실행
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeData();
    });
  }

  Future<void> _initializeData() async {
    print("11111");
    String requestUrl = "http://localhost:8080/api/v1/shop/page?pageNo=" + "0";
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
        final Map<String, dynamic> jsonResponse = Map<String, dynamic>.from(jsonDecode(utf8.decode(response.bodyBytes)));
        final List<dynamic> contentList = jsonResponse['content'] as List<dynamic>;

        // Update imagePaths list and rebuild UI
        setState(() {
          imagePaths = contentList.map((item) => item['imageRoot'].toString()).toList();
          itemNames = contentList.map((item) => item['itemName'].toString()).toList();
          itemLore = contentList.map((item) => item['itemDescription'].toString()).toList();
          itemPrice = contentList.map((item) => item['price'].toString()).toList();
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
      print('Error: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('서버 연결에 실패했습니다.')),
        );
      }
    }
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
                        const Text(
                          '0',
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
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
      body: Column(
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
                                width: MediaQuery.of(context).size.width > 600 
                                    ? (MediaQuery.of(context).size.width * 0.6 / 5).clamp(50, 90)  // 크기를 50~90 사이로 제한
                                    : (MediaQuery.of(context).size.width * 0.7 / 5).clamp(40, 70),
                                height: MediaQuery.of(context).size.width > 600 
                                    ? (MediaQuery.of(context).size.width * 0.6 / 5).clamp(50, 90)
                                    : (MediaQuery.of(context).size.width * 0.7 / 5).clamp(40, 70),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  border: Border.all(color: Colors.black),
                                ),
                                child: imagePaths.isNotEmpty
                                    ? Image.asset(
                                        'images/items/${imagePaths[selectedIndex]}',
                                        fit: BoxFit.contain,
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
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
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
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
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
          const SizedBox(height: 3),
          Expanded(
            child: GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
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
                        content: Text('${imagePaths[index]}번째 물건입니다.'),
                        duration: const Duration(milliseconds: 250),
                      ),
                    );
                  },
                  child: Container(
                    margin: const EdgeInsets.all(2),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
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
                        : Image.asset(
                            'images/items/${imagePaths[index]}',
                            fit: BoxFit.cover,
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
                      print('가방을 클릭했습니다.');
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
