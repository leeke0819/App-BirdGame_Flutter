import 'dart:convert' show json, utf8;
import 'package:bird_raise_app/config/env_config.dart';
import 'package:flutter/foundation.dart' show kIsWeb, listEquals;
import 'package:http/http.dart' as http;
import 'package:bird_raise_app/token/chrome_token.dart';
import 'package:bird_raise_app/token/mobile_secure_token.dart';
import 'package:flutter/services.dart';

class ApiCrafting {
  static final Uri _baseUrl =
      Uri.parse('${EnvConfig.apiUrl}/craft?itemCode=item_001');

  static Future<void> craft(String itemCode) async {
    String? token;
    if (kIsWeb) {
      token = getChromeAccessToken();
    } else {
      token = await getAccessToken();
    }

    final response = await http.post(
      _baseUrl,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json; charset=utf-8',
      },
    );
    print(response.body);
  }

  // 조합 레시피 로드
  static Future<Map<String, List<String>>> loadCraftingRecipes() async {
    try {
      print('craft.json 파일 로드 시작...');
      final String jsonString = await rootBundle.loadString('craft.json');
      print('JSON 문자열 로드 완료: $jsonString');

      final Map<String, dynamic> jsonData = json.decode(jsonString);
      print('JSON 파싱 완료: $jsonData');

      Map<String, List<String>> craftingRecipes =
          Map<String, List<String>>.from(jsonData
              .map((key, value) => MapEntry(key, List<String>.from(value))));

      print('조합 레시피 로드 완료: $craftingRecipes');
      return craftingRecipes;
    } catch (e) {
      print('조합 레시피 로드 실패: $e');
      print('에러 상세 정보: ${e.toString()}');
      return {};
    }
  }

  // 서버에서 아이템 정보 가져오기
  static Future<Map<String, dynamic>?> getItemInfo(String itemCode) async {
    try {
      String? token;
      if (kIsWeb) {
        token = getChromeAccessToken();
      } else {
        token = await getAccessToken();
      }

      final response = await http.get(
        Uri.parse('${EnvConfig.apiUrl}/shop'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json; charset=utf-8',
        },
      );

      if (response.statusCode == 200) {
        // UTF-8 인코딩으로 디코딩
        final List<dynamic> itemsData =
            json.decode(utf8.decode(response.bodyBytes));
        // itemCode로 해당 아이템 찾기
        for (var item in itemsData) {
          if (item['itemCode'] == itemCode) {
            return item;
          }
        }
        return null;
      } else {
        print('아이템 정보 가져오기 실패: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      print('아이템 정보 가져오기 오류: $e');
      return null;
    }
  }

  // 결과 아이템 이미지 경로 매핑 (서버에서 가져오기)
  static Future<String> getResultItemImagePath(String itemCode) async {
    Map<String, dynamic>? itemInfo = await getItemInfo(itemCode);
    if (itemInfo != null && itemInfo['imageRoot'] != null) {
      return 'images/items/${itemInfo['imageRoot'].toString()}';
    }

    // 서버에서 가져오기 실패시 기본 매핑 사용
    Map<String, String> itemImageMapping = {
      'item_001': 'sun_flower_seed_v1.png',
      'item_002': 'sun_flower_seed_v2.png',
      'item_003': 'peanut_v1.png',
      'item_004': 'peanut_v2.png',
      'item_005': 'apple.png',
      'item_006': 'gamgyul.png',
      'item_007': 'grape.png',
      'item_008': 'banana.png',
      'item_009': 'blue_berry.png',
      'item_010': 'black_berry.png',
      'item_011': 'rasp_berry.png',
      'item_012': 'cran_berry.png',
      'item_013': 'water_bottle.png',
    };

    String imageFileName = itemImageMapping[itemCode] ?? 'apple.png';
    return 'images/items/$imageFileName';
  }

  // 결과 아이템 이름 매핑 (서버에서 가져오기)
  static Future<String> getResultItemName(String itemCode) async {
    Map<String, dynamic>? itemInfo = await getItemInfo(itemCode);
    if (itemInfo != null && itemInfo['itemName'] != null) {
      return itemInfo['itemName'].toString();
    }

    // 서버에서 가져오기 실패시 기본 매핑 사용
    Map<String, String> itemNameMapping = {
      'item_001': '껍질이 있는 해바라기 씨앗',
      'item_002': '껍질이 없는 해바라기 씨앗',
      'item_003': '껍질이 있는 땅콩',
      'item_004': '껍질이 없는 땅콩',
      'item_005': '사과',
      'item_006': '귤',
      'item_007': '포도',
      'item_008': '바나나',
      'item_009': '블루베리',
      'item_010': '블랙베리',
      'item_011': '라즈베리',
      'item_012': '크랜베리',
      'item_013': '물병',
    };
    return itemNameMapping[itemCode] ?? '알 수 없는 아이템';
  }

  // 결과 아이템 설명 매핑 (서버에서 가져오기)
  static Future<String> getResultItemDescription(String itemCode) async {
    Map<String, dynamic>? itemInfo = await getItemInfo(itemCode);
    if (itemInfo != null && itemInfo['itemDescription'] != null) {
      return itemInfo['itemDescription'].toString();
    }

    // 서버에서 가져오기 실패시 기본 매핑 사용
    Map<String, String> itemDescriptionMapping = {
      'item_001': '껍질이 있는 해바라기 씨앗입니다. 껍질이 있어, 아기새에게는 먹이기 힘들어 보입니다.',
      'item_002': '껍질이 없는 해바라기 씨앗입니다.',
      'item_003': '껍질이 있는 땅콩입니다. 껍질이 있어, 아기새에게는 먹이기 힘들어 보입니다.',
      'item_004': '껍질이 없는 땅콩입니다.',
      'item_005': '잘 익은 사과입니다.',
      'item_006': '잘 익은 귤입니다.',
      'item_007': '잘 익은 포도입니다.',
      'item_008': '잘 익은 바나나입니다.',
      'item_009': '잘 익은 블루베리입니다.',
      'item_010': '잘 익은 블랙베리입니다.',
      'item_011': '잘 익은 라즈베리입니다.',
      'item_012': '잘 익은 크랜베리입니다.',
      'item_013': '물이 담겨있는 물병입니다.',
    };
    return itemDescriptionMapping[itemCode] ?? '조합으로 만든 아이템입니다.';
  }

  // 조합 레시피 확인
  static Future<Map<String, dynamic>> checkCraftingRecipe(
      List<String> craftingSlotCodes,
      Map<String, List<String>> craftingRecipes) async {
    // 현재 조합 창의 아이템 코드들을 정렬
    List<String> currentRecipe =
        craftingSlotCodes.where((code) => code.isNotEmpty).toList()..sort();

    // 레시피에서 매칭되는 조합 찾기
    String? matchedRecipe = null;
    List<String>? matchedIngredients = null;

    print('=== 조합 디버그 정보 ===');
    print('현재 조합 창: $craftingSlotCodes');
    print('현재 조합 (정렬됨): $currentRecipe');
    print('사용 가능한 레시피: $craftingRecipes');

    for (String resultCode in craftingRecipes.keys) {
      List<String> recipeIngredients =
          List<String>.from(craftingRecipes[resultCode]!)..sort();

      print('레시피 $resultCode: $recipeIngredients');
      print('현재 조합과 비교: ${listEquals(currentRecipe, recipeIngredients)}');

      if (listEquals(currentRecipe, recipeIngredients)) {
        matchedRecipe = resultCode;
        matchedIngredients = recipeIngredients;
        break;
      }
    }

    bool canCraft = matchedRecipe != null;
    String resultItemCode = matchedRecipe ?? '';
    String resultItem = '';

    if (canCraft && matchedRecipe != null) {
      resultItem = await getResultItemImagePath(matchedRecipe!);
    }

    print('매칭된 레시피: $matchedRecipe');
    print('조합 가능 여부: $canCraft');
    print('========================');

    return {
      'canCraft': canCraft,
      'resultItemCode': resultItemCode,
      'resultItem': resultItem,
      'matchedRecipe': matchedRecipe,
    };
  }
}
