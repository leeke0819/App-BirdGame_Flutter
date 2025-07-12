import 'package:flutter/material.dart';
import 'package:bird_raise_app/api/api_book.dart';
import 'package:bird_raise_app/gui_click_pages/shop_page.dart';
import 'package:bird_raise_app/gui_click_pages/bag_page.dart';
import 'package:bird_raise_app/gui_click_pages/adventure_page.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'package:bird_raise_app/model/gold_model.dart';

class BookPage extends StatefulWidget {
  const BookPage({super.key});

  @override
  State<BookPage> createState() => _BookPageState();
}

class _BookPageState extends State<BookPage> {
  List<dynamic>? shopData;
  bool isLoading = true;
  int category = 1; // 기본 카테고리

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  Future<void> fetchData() async {
    // 새로운 완전한 도감 API 사용
    final completeBookResult = await ApiBook.getCompleteBookList(category);
    
    setState(() {
      shopData = completeBookResult;
      isLoading = false;
    });
  }

  // 아이템이 획득되었는지 확인 (새로운 API 구조에 맞춤)
  bool isItemObtained(dynamic item) {
    return item['obtained'] == true;
  }

  // 아이템이 알인지 확인
  bool isItemEgg(dynamic item) {
    return item['isEgg'] == true;
  }

  // 아이템이 표시 가능한지 확인
  bool isItemDisplay(dynamic item) {
    return item['isDisplay'] == true;
  }

  @override
  Widget build(BuildContext context) {
    final goldModel = context.watch<GoldModel>();
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          '도감',
          style: TextStyle(
            fontFamily: 'NaverNanumSquareRound',
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : shopData == null
              ? const Center(child: Text('데이터를 불러올 수 없습니다.'))
              : Column(
                  children: [
                    // 카테고리 선택 버튼
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Row(
                        children: [
                          Expanded(
                            child: GestureDetector(
                              onTap: () async {
                                setState(() {
                                  category = 1;
                                  isLoading = true;
                                });
                                await fetchData();
                              },
                              child: Container(
                                height: 50,
                                decoration: BoxDecoration(
                                  color: category == 1 ? Colors.blue : Colors.blue[100]!,
                                  border: Border.all(
                                    color: category == 1 ? Colors.blue[700]! : Colors.blue[300]!,
                                    width: 2,
                                  ),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Center(
                                  child: Text(
                                    '재료',
                                    style: TextStyle(
                                      color: category == 1 ? Colors.white : Colors.black,
                                      fontWeight: category == 1 ? FontWeight.bold : FontWeight.normal,
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
                                setState(() {
                                  category = 2;
                                  isLoading = true;
                                });
                                await fetchData();
                              },
                              child: Container(
                                height: 50,
                                decoration: BoxDecoration(
                                  color: category == 2 ? Colors.green : Colors.green[100]!,
                                  border: Border.all(
                                    color: category == 2 ? Colors.green[700]! : Colors.green[300]!,
                                    width: 2,
                                  ),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Center(
              child: Text(
                                    '새알',
                                    style: TextStyle(
                                      color: category == 2 ? Colors.white : Colors.black,
                                      fontWeight: category == 2 ? FontWeight.bold : FontWeight.normal,
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
                    // 도감 그리드
                    Expanded(
                      child: GridView.builder(
                        padding: const EdgeInsets.all(2.0), // 패딩 줄임
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 5,
                          mainAxisSpacing: 3, // 간격 줄임
                          crossAxisSpacing: 3, // 간격 줄임
                          childAspectRatio: 1.0, // 비율 원래대로
                        ),
                        itemCount: shopData!.length,
                        itemBuilder: (context, index) {
                          final item = shopData![index];
                          final itemCode = item['itemCode'].toString();
                          final imagePath = item['imageRoot'].toString();
                          final itemName = item['itemName'].toString();
                          final itemDescription = item['itemDescription'].toString();          
                          final isObtained = isItemObtained(item);

                          return GestureDetector(
                            onTap: () {
                              showDialog(
                                context: context,
                                builder: (context) => AlertDialog(
                                  title: Text(
                                    itemName,
                                    style: const TextStyle(fontFamily: 'NaverNanumSquareRound'),
                                  ),
                                  content: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
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
                                        child: Opacity(
                                          opacity: isObtained ? 1.0 : 0.3,
                                          child: Padding(
                                            padding: const EdgeInsets.all(8.0),
                                            child: Image.asset(
                                              'images/items/$imagePath',
                                              fit: BoxFit.contain,
                                            ),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(height: 16),
                                      Text(
                                        isObtained ? '획득 완료!' : '미획득',
                                        style: TextStyle(
                                          color: isObtained ? Colors.green : Colors.grey,
                                          fontWeight: FontWeight.bold,
                                          fontFamily: 'NaverNanumSquareRound',
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        itemDescription,
                                        textAlign: TextAlign.center,
                                        style: const TextStyle(
                                          fontSize: 12,
                                          fontFamily: 'NaverNanumSquareRound',
                                        ),
                                      ),
                                    ],
                                  ),
                                  actions: [
                                    TextButton(
                                      onPressed: () => Navigator.of(context).pop(),
                                      child: const Text('닫기'),
                                    ),
                                  ],
                                ),
                              );
                            },
                            child: Container(
                              margin: const EdgeInsets.all(1), // 여백 줄임
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(8),
                                image: const DecorationImage(
                                  image: AssetImage('images/background/shop_item_background.png'),
                                  fit: BoxFit.cover,
                                ),
                              ),
                              child: Stack(
                                children: [
                                  Center(
                                    child: Opacity(
                                      opacity: isObtained ? 1.0 : 0.3,
                                      child: Padding(
                                        padding: const EdgeInsets.all(8.0), // 패딩 더 줄임
                                        child: Image.asset(
                                            'images/items/$imagePath',
                                            fit: BoxFit.contain,
                                          ),
                                      ),
                                    ),
                                  ),
                                  if (!isObtained)
                                    Positioned(
                                      top: 4,
                                      right: 4,
                                      child: Container(
                                        width: 16,
                                        height: 16,
                                        decoration: const BoxDecoration(
                                          color: Colors.grey,
                                          shape: BoxShape.circle,
                                        ),
                                        child: const Icon(
                                          Icons.question_mark,
                                          size: 12,
                                          color: Colors.white,
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
                          ),
                          Expanded(
                            child: GestureDetector(
                              onTap: () async {
                                await Get.off(() => const AdventurePage());
                              },
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
                          ),
                          Expanded(
                            child: GestureDetector(
                              onTap: () async {
                                Get.off(() => const ShopPage());
                                await goldModel.fetchGold();
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
                                await goldModel.fetchGold();
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