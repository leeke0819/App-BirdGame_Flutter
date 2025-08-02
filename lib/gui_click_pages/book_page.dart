import 'package:bird_raise_app/main_page.dart';
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
    print(item);
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
        automaticallyImplyLeading: false,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Get.off(() => const MainPage()),
        ),
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
              : Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.purple[100]!,
                        Colors.purple[200]!,
                      ],
                    ),
                  ),
                  child: Column(
                    children: [
                      // 카테고리 선택 버튼
                      Container(
                        margin: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.9),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.purple[300]!, width: 2),
                        ),
                        child: Padding(
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
                      ),
                      // 도감 그리드
                      Expanded(
                        child: GridView.builder(
                          padding: const EdgeInsets.all(16),
                          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 5,
                            mainAxisSpacing: 4,
                            crossAxisSpacing: 4,
                            childAspectRatio: 1.0,
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
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(
                                    color: isObtained ? Colors.green : Colors.grey[300]!,
                                    width: isObtained ? 2 : 1,
                                  ),
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
                                          padding: const EdgeInsets.all(8.0),
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
                                    FractionallySizedBox(
                                      widthFactor: 0.90,
                                      heightFactor: 0.90,
                                      child: Image.asset(
                                        'images/GUI/bag_GUI.png',
                                        fit: BoxFit.contain,
                                      ),
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