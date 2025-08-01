import 'package:bird_raise_app/api/api_bag.dart';
import 'package:bird_raise_app/api/api_bird.dart';
import 'package:bird_raise_app/api/api_crafting.dart';
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
import 'package:flutter/foundation.dart' show kIsWeb, kDebugMode;
import 'package:bird_raise_app/token/mobile_secure_token.dart';
import 'package:provider/provider.dart';

class CraftingPage extends StatefulWidget {
  const CraftingPage({super.key});

  @override
  State<CraftingPage> createState() => _CraftingPageState();
}

class _CraftingPageState extends State<CraftingPage>
    with TickerProviderStateMixin {
  List<String> imagePaths = [];
  List<String> itemNames = [];
  List<String> itemLore = [];
  List<String> itemAmounts = [];
  List<String> itemCode = [];
  int selectedIndex = 0;
  bool _isLoading = true;

  // 조합 창 관련 변수들
  List<String> craftingSlots = List.filled(3, ''); // 3x1 조합 창
  List<String> craftingSlotCodes = List.filled(3, ''); // 아이템 코드 저장
  String resultItem = ''; // 조합 결과 아이템
  String resultItemCode = ''; // 결과 아이템 코드
  bool canCraft = false; // 조합 가능 여부

  // 조합 레시피 데이터
  Map<String, List<String>> craftingRecipes = {};

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
      // 조합 레시피 로드
      await _loadCraftingRecipes();

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

  // craft.json 파일 로드
  Future<void> _loadCraftingRecipes() async {
    try {
      craftingRecipes = await ApiCrafting.loadCraftingRecipes();
    } catch (e) {
      print('조합 레시피 로드 실패: $e');
      print('에러 상세 정보: ${e.toString()}');
    }
  }

  // 조합 창에 아이템 추가
  void addToCraftingSlot(int slotIndex) {
    if (selectedIndex < imagePaths.length) {
      setState(() {
        craftingSlots[slotIndex] = imagePaths[selectedIndex];
        craftingSlotCodes[slotIndex] = itemCode[selectedIndex];
        print(
            '아이템 추가: ${imagePaths[selectedIndex]} -> ${itemCode[selectedIndex]}');
        checkCraftingRecipe();
      });
    }
  }

  // 조합 창에서 아이템 제거
  void removeFromCraftingSlot(int slotIndex) {
    setState(() {
      craftingSlots[slotIndex] = '';
      craftingSlotCodes[slotIndex] = '';
      checkCraftingRecipe();
    });
  }

  // 조합 레시피 확인
  Future<void> checkCraftingRecipe() async {
    Map<String, dynamic> result = await ApiCrafting.checkCraftingRecipe(
        craftingSlotCodes, craftingRecipes);

    setState(() {
      canCraft = result['canCraft'];
      resultItemCode = result['resultItemCode'];
      resultItem = result['resultItem'];
    });
  }

  // 결과 아이템 이미지 경로 매핑
  Future<String> _getResultItemImagePath(String itemCode) async {
    return await ApiCrafting.getResultItemImagePath(itemCode);
  }

  // 조합 실행
  Future<void> executeCrafting() async {
    if (canCraft && resultItem.isNotEmpty) {
      // 조합 로직 구현
      print('조합 실행: $resultItemCode');

      // 조합 완료 후 가방 데이터 새로고침
      await _refreshBagData();

      // 조합 창 초기화
      setState(() {
        craftingSlots = List.filled(3, '');
        craftingSlotCodes = List.filled(3, '');
        resultItem = '';
        resultItemCode = '';
        canCraft = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('$resultItemCode 조합이 완료되었습니다!',
              style: const TextStyle(fontFamily: 'NaverNanumSquareRound')),
        ),
      );
    }
  }

  // 조합 재료 소모
  void _consumeCraftingMaterials() {
    // 사용된 아이템들의 수량을 차감
    for (int i = 0; i < craftingSlotCodes.length; i++) {
      if (craftingSlotCodes[i].isNotEmpty) {
        // 해당 아이템의 인덱스 찾기
        int itemIndex = itemCode.indexOf(craftingSlotCodes[i]);
        if (itemIndex != -1) {
          // 현재 수량 가져오기
          int currentAmount = int.tryParse(itemAmounts[itemIndex]) ?? 0;
          if (currentAmount > 0) {
            // 수량 차감
            int newAmount = currentAmount - 1;
            setState(() {
              itemAmounts[itemIndex] = newAmount.toString();
            });

            // 수량이 0이 되면 아이템 제거
            if (newAmount <= 0) {
              setState(() {
                imagePaths.removeAt(itemIndex);
                itemNames.removeAt(itemIndex);
                itemLore.removeAt(itemIndex);
                itemAmounts.removeAt(itemIndex);
                itemCode.removeAt(itemIndex);

                // 선택된 인덱스 조정
                if (selectedIndex >= itemIndex && selectedIndex > 0) {
                  selectedIndex--;
                }
              });
            }
          }
        }
      }
    }
  }

  // 조합 결과 아이템을 가방에 추가
  Future<void> _addCraftedItemToBag() async {
    if (resultItemCode.isNotEmpty) {
      // 조합 결과 아이템 정보
      String resultImagePath = await _getResultItemImagePath(resultItemCode);
      String resultItemName = await _getResultItemName(resultItemCode);
      String resultItemDescription =
          await _getResultItemDescription(resultItemCode);

      // 가방에 추가
      setState(() {
        imagePaths.add(resultImagePath.replaceFirst('images/items/', ''));
        itemNames.add(resultItemName);
        itemLore.add(resultItemDescription);
        itemAmounts.add('1');
        itemCode.add(resultItemCode);
      });
    }
  }

  // 결과 아이템 이름 매핑
  Future<String> _getResultItemName(String itemCode) async {
    return await ApiCrafting.getResultItemName(itemCode);
  }

  // 결과 아이템 설명 매핑
  Future<String> _getResultItemDescription(String itemCode) async {
    return await ApiCrafting.getResultItemDescription(itemCode);
  }

  // 가방 데이터 새로고침
  Future<void> _refreshBagData() async {
    try {
      final items = await fetchBagData();
      setState(() {
        imagePaths = items.map((item) => item['imagePath'] ?? '').toList();
        itemNames = items.map((item) => item['itemName'] ?? '').toList();
        itemLore = items.map((item) => item['itemDescription'] ?? '').toList();
        itemAmounts = items.map((item) => item['amount'] ?? '').toList();
        itemCode = items.map((item) => item['itemCode'] ?? '').toList();
      });
    } catch (e) {
      print('가방 데이터 새로고침 실패: $e');
    }
  }

  // API를 사용한 조합 실행
  Future<void> _executeCraftingWithApi() async {
    try {
      print('조합 API 호출: $resultItemCode');
      await ApiCrafting.craft(resultItemCode);
      if (kDebugMode) {
        print('API 조합 결과 완료');
      }

      // 조합 완료 후 가방 데이터 새로고침
      await _refreshBagData();

      // 조합 창 초기화
      setState(() {
        craftingSlots = List.filled(3, '');
        craftingSlotCodes = List.filled(3, '');
        resultItem = '';
        resultItemCode = '';
        canCraft = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('$resultItemCode 조합이 완료되었습니다!',
              style: const TextStyle(fontFamily: 'NaverNanumSquareRound')),
        ),
      );
    } catch (e) {
      print('조합 API 호출 실패: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('조합에 실패했습니다. 다시 시도해주세요.',
              style: const TextStyle(fontFamily: 'NaverNanumSquareRound')),
          backgroundColor: Colors.red,
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
                                        image: AssetImage(
                                            'images/background/shop_item_background.png'),
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
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
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
                                          itemLore.isNotEmpty
                                              ? itemLore[selectedIndex]
                                              : '',
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
                              gridDelegate:
                                  const SliverGridDelegateWithFixedCrossAxisCount(
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
                                        image: AssetImage(
                                            'images/background/shop_item_background.png'),
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
                                              borderRadius:
                                                  BorderRadius.circular(4),
                                            ),
                                            child: Text(
                                              itemAmounts[index],
                                              style: const TextStyle(
                                                color: Colors.white,
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
                                        border: Border.all(
                                            color: Colors.brown[400]!,
                                            width: 2),
                                      ),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceEvenly,
                                        children: List.generate(3, (index) {
                                          return Expanded(
                                            child: Container(
                                              margin: const EdgeInsets.all(4),
                                              child: GestureDetector(
                                                onTap: () {
                                                  if (craftingSlots[index]
                                                      .isNotEmpty) {
                                                    removeFromCraftingSlot(
                                                        index);
                                                  } else if (imagePaths
                                                      .isNotEmpty) {
                                                    addToCraftingSlot(index);
                                                  }
                                                },
                                                child: Container(
                                                  height: 60,
                                                  decoration: BoxDecoration(
                                                    color: Colors.white,
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            4),
                                                    border: Border.all(
                                                        color:
                                                            Colors.grey[400]!),
                                                  ),
                                                  child: craftingSlots[index]
                                                          .isNotEmpty
                                                      ? Stack(
                                                          children: [
                                                            Center(
                                                              child: Padding(
                                                                padding:
                                                                    const EdgeInsets
                                                                        .all(
                                                                        4.0),
                                                                child:
                                                                    Image.asset(
                                                                  'images/items/${craftingSlots[index]}',
                                                                  fit: BoxFit
                                                                      .contain,
                                                                ),
                                                              ),
                                                            ),
                                                            Positioned(
                                                              top: 2,
                                                              right: 2,
                                                              child:
                                                                  GestureDetector(
                                                                onTap: () =>
                                                                    removeFromCraftingSlot(
                                                                        index),
                                                                child:
                                                                    Container(
                                                                  width: 16,
                                                                  height: 16,
                                                                  decoration:
                                                                      BoxDecoration(
                                                                    color: Colors
                                                                        .red,
                                                                    borderRadius:
                                                                        BorderRadius
                                                                            .circular(8),
                                                                  ),
                                                                  child:
                                                                      const Icon(
                                                                    Icons.close,
                                                                    size: 12,
                                                                    color: Colors
                                                                        .white,
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
                                        border: Border.all(
                                            color: Colors.brown[400]!,
                                            width: 2),
                                      ),
                                      child: Center(
                                        child: resultItem.isNotEmpty
                                            ? Container(
                                                width: 60,
                                                height: 60,
                                                decoration: BoxDecoration(
                                                  borderRadius:
                                                      BorderRadius.circular(8),
                                                  image: const DecorationImage(
                                                    image: AssetImage(
                                                        'images/background/shop_item_background.png'),
                                                    fit: BoxFit.cover,
                                                  ),
                                                ),
                                                child: Padding(
                                                  padding:
                                                      const EdgeInsets.all(8.0),
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
                            child: GestureDetector(
                              onTap: canCraft
                                  ? () {
                                      _executeCraftingWithApi();
                                    }
                                  : null,
                              child: Container(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 12),
                                decoration: BoxDecoration(
                                  color: canCraft ? Colors.green : Colors.grey,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Center(
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
