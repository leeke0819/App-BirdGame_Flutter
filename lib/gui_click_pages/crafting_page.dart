import 'dart:convert';
import 'package:bird_raise_app/api/api_bag.dart';
import 'package:bird_raise_app/api/api_bird.dart';
import 'package:bird_raise_app/gui_click_pages/adventure_page.dart';
import 'package:bird_raise_app/gui_click_pages/book_page.dart';
import 'package:bird_raise_app/gui_click_pages/shop_page.dart';
import 'package:bird_raise_app/main_page.dart';
import 'package:bird_raise_app/model/bag_model.dart';
import 'package:bird_raise_app/model/gold_model.dart';
import 'package:bird_raise_app/token/chrome_token.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:bird_raise_app/token/mobile_secure_token.dart';
import 'package:provider/provider.dart';

class CraftingPage extends StatefulWidget {
  const CraftingPage({super.key});

  @override
  State<CraftingPage> createState() => _CraftingPageState();
}

class _CraftingPageState extends State<CraftingPage> with TickerProviderStateMixin {
  List<String> imagePaths = [];
  List<String> itemNames = [];
  List<String> itemLore = [];
  List<String> itemAmounts = [];
  List<String> itemCode = [];
  int selectedIndex = 0;
  bool _isLoading = true;

  // 조합 창 관련 변수들
  List<String> craftingSlots = List.filled(3, ''); // 3x1 조합 창
  String resultItem = ''; // 조합 결과 아이템
  bool canCraft = false; // 조합 가능 여부

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeData();
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

  // 조합 창에 아이템 추가
  void addToCraftingSlot(int slotIndex) {
    if (selectedIndex < imagePaths.length) {
      setState(() {
        craftingSlots[slotIndex] = imagePaths[selectedIndex];
        checkCraftingRecipe();
      });
    }
  }

  // 조합 창에서 아이템 제거
  void removeFromCraftingSlot(int slotIndex) {
    setState(() {
      craftingSlots[slotIndex] = '';
      checkCraftingRecipe();
    });
  }

  // 조합 레시피 확인
  void checkCraftingRecipe() {
    // 여기에 실제 조합 레시피 로직을 구현
    // 예시: 모든 슬롯이 채워져 있으면 조합 가능
    bool allSlotsFilled = craftingSlots.every((slot) => slot.isNotEmpty);
    
    setState(() {
      canCraft = allSlotsFilled;
      if (canCraft) {
        resultItem = 'images/items/apple.png'; // 예시 결과 아이템
      } else {
        resultItem = '';
      }
    });
  }

  // 조합 실행
  void executeCrafting() {
    if (canCraft && resultItem.isNotEmpty) {
      // 조합 로직 구현
      print('조합 실행: $resultItem');
      
      // 조합 창 초기화
      setState(() {
        craftingSlots = List.filled(3, '');
        resultItem = '';
        canCraft = false;
      });
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('조합이 완료되었습니다!',
              style: TextStyle(fontFamily: 'NaverNanumSquareRound')),
        ),
      );
    }
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
        backgroundColor: Colors.brown[200],
        title: const Text(
          '제작대',
          style: TextStyle(
            fontFamily: 'NaverNanumSquareRound',
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
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
                    Colors.brown[100]!,
                    Colors.brown[200]!,
                  ],
                ),
              ),
              child: Column(
                children: [
                  // 상단: 가방 아이템 목록
                  Expanded(
                    flex: 2,
                    child: Container(
                      margin: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.9),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.brown[300]!, width: 2),
                      ),
                      child: Column(
                        children: [
                          // 제목
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            decoration: BoxDecoration(
                              color: Colors.brown[300],
                              borderRadius: const BorderRadius.only(
                                topLeft: Radius.circular(10),
                                topRight: Radius.circular(10),
                              ),
                            ),
                            child: const Text(
                              '가방 아이템',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontFamily: 'NaverNanumSquareRound',
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                                fontSize: 16,
                              ),
                            ),
                          ),
                          // 선택된 아이템 정보
                          if (imagePaths.isNotEmpty)
                            Container(
                              padding: const EdgeInsets.all(12),
                              child: Row(
                                children: [
                                  // 선택된 아이템 이미지
                                  Container(
                                    width: 60,
                                    height: 60,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(8),
                                      image: const DecorationImage(
                                        image: AssetImage('images/background/shop_item_background.png'),
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                    child: Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Image.asset(
                                        'images/items/${imagePaths[selectedIndex]}',
                                        fit: BoxFit.contain,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
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
                                        const SizedBox(height: 4),
                                        Text(
                                          '수량: ${itemAmounts.isNotEmpty ? itemAmounts[selectedIndex] : '0'}',
                                          style: TextStyle(
                                            fontSize: 14,
                                            color: Colors.grey[600],
                                            fontFamily: 'NaverNanumSquareRound',
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          itemLore.isNotEmpty ? itemLore[selectedIndex] : '',
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: Colors.grey[500],
                                            fontFamily: 'NaverNanumSquareRound',
                                          ),
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          // 아이템 그리드
                          Expanded(
                            child: GridView.builder(
                              padding: const EdgeInsets.all(8),
                              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 5,
                                mainAxisSpacing: 4,
                                crossAxisSpacing: 4,
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
                                      ],
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  // 하단: 조합 창
                  Expanded(
                    flex: 3,
                    child: Container(
                      margin: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.9),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.brown[300]!, width: 2),
                      ),
                      child: Column(
                        children: [
                          // 제목
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            decoration: BoxDecoration(
                              color: Colors.brown[300],
                              borderRadius: const BorderRadius.only(
                                topLeft: Radius.circular(10),
                                topRight: Radius.circular(10),
                              ),
                            ),
                            child: const Text(
                              '조합하기',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontFamily: 'NaverNanumSquareRound',
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                                fontSize: 16,
                              ),
                            ),
                          ),
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Row(
                                children: [
                                  // 3x1 조합 창
                                  Expanded(
                                    flex: 3,
                                    child: Container(
                                      decoration: BoxDecoration(
                                        color: Colors.grey[200],
                                        borderRadius: BorderRadius.circular(8),
                                        border: Border.all(color: Colors.brown[400]!, width: 2),
                                      ),
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                        children: List.generate(3, (index) {
                                          return Expanded(
                                            child: Container(
                                              margin: const EdgeInsets.all(4),
                                              child: GestureDetector(
                                                onTap: () {
                                                  if (craftingSlots[index].isNotEmpty) {
                                                    removeFromCraftingSlot(index);
                                                  } else if (imagePaths.isNotEmpty) {
                                                    addToCraftingSlot(index);
                                                  }
                                                },
                                                child: Container(
                                                  height: 60,
                                                  decoration: BoxDecoration(
                                                    color: Colors.white,
                                                    borderRadius: BorderRadius.circular(4),
                                                    border: Border.all(color: Colors.grey[400]!),
                                                  ),
                                                  child: craftingSlots[index].isNotEmpty
                                                      ? Stack(
                                                          children: [
                                                            Center(
                                                              child: Padding(
                                                                padding: const EdgeInsets.all(4.0),
                                                                child: Image.asset(
                                                                  'images/items/${craftingSlots[index]}',
                                                                  fit: BoxFit.contain,
                                                                ),
                                                              ),
                                                            ),
                                                            Positioned(
                                                              top: 2,
                                                              right: 2,
                                                              child: GestureDetector(
                                                                onTap: () => removeFromCraftingSlot(index),
                                                                child: Container(
                                                                  width: 16,
                                                                  height: 16,
                                                                  decoration: BoxDecoration(
                                                                    color: Colors.red,
                                                                    borderRadius: BorderRadius.circular(8),
                                                                  ),
                                                                  child: const Icon(
                                                                    Icons.close,
                                                                    size: 12,
                                                                    color: Colors.white,
                                                                  ),
                                                                ),
                                                              ),
                                                            ),
                                                          ],
                                                        )
                                                      : const Center(
                                                          child: Icon(
                                                            Icons.add,
                                                            color: Colors.grey,
                                                            size: 20,
                                                          ),
                                                        ),
                                                ),
                                              ),
                                            ),
                                          );
                                        }),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  // 화살표
                                  const Expanded(
                                    flex: 1,
                                    child: Center(
                                      child: Icon(
                                        Icons.arrow_forward,
                                        size: 32,
                                        color: Colors.brown,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  // 결과 아이템
                                  Expanded(
                                    flex: 2,
                                    child: Container(
                                      decoration: BoxDecoration(
                                        color: Colors.grey[200],
                                        borderRadius: BorderRadius.circular(8),
                                        border: Border.all(color: Colors.brown[400]!, width: 2),
                                      ),
                                      child: Center(
                                        child: resultItem.isNotEmpty
                                            ? Container(
                                                width: 60,
                                                height: 60,
                                                decoration: BoxDecoration(
                                                  borderRadius: BorderRadius.circular(8),
                                                  image: const DecorationImage(
                                                    image: AssetImage('images/background/shop_item_background.png'),
                                                    fit: BoxFit.cover,
                                                  ),
                                                ),
                                                child: Padding(
                                                  padding: const EdgeInsets.all(8.0),
                                                  child: Image.asset(
                                                    resultItem,
                                                    fit: BoxFit.contain,
                                                  ),
                                                ),
                                              )
                                            : const Icon(
                                                Icons.question_mark,
                                                size: 40,
                                                color: Colors.grey,
                                              ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          // 조합 버튼
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(16),
                            child: ElevatedButton(
                              onPressed: canCraft ? executeCrafting : null,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: canCraft ? Colors.green : Colors.grey,
                                padding: const EdgeInsets.symmetric(vertical: 12),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              child: Text(
                                canCraft ? '조합하기' : '조합 불가',
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  fontFamily: 'NaverNanumSquareRound',
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  // 하단 네비게이션 바
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
                              Get.off(() => const MainPage());
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