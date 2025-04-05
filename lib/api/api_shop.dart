import 'dart:convert';

import 'package:bird_raise_app/token/chrome_token.dart';
import 'package:http/http.dart' as http;

String baseUrl = "http://localhost:8080/api/v1/shop";
int userMoney = 0;
bool isDataLoaded = false;

//사용자 아이템 구매하기
Future<int> buyItem(String itemCode) async {
  print("$itemCode구매 시도");
  String? token = getChromeAccessToken();
  String? bearerToken = "Bearer $token";

  final response = await http.post(Uri.parse("$baseUrl/buy?itemCode=$itemCode"),
      headers: {'Authorization': bearerToken});

  if (response.statusCode == 200) {
    final Map<String, dynamic> jsonResponse =
        Map<String, dynamic>.from(jsonDecode(utf8.decode(response.bodyBytes)));

    // 서버 응답 파싱
    String status = jsonResponse['buy_status'];
    int money = jsonResponse['user_money'];

    // 전역 변수 업데이트 (GUI 갱신)
    userMoney = money;
    isDataLoaded = true;

    print("구매 상태 : $status, 현재 골드 : $money");
    return 1;
  } else if (response.statusCode == 400) {
    final Map<String, dynamic> errorResponse =
        Map<String, dynamic>.from(jsonDecode(utf8.decode(response.bodyBytes)));

    print("구매 실패 : ${errorResponse['error_message']}");
    return 0;
  }
  return 0;
}

// 사용자 아이템 판매하기
Future<int> sellItem(String itemCode) async {
  print("$itemCode판매 시도");
  String? token = getChromeAccessToken();
  String? bearerToken = "Bearer $token";

  final response = await http.post(
      Uri.parse("$baseUrl/sell?itemCode=$itemCode"),
      headers: {'Authorization': bearerToken});

  if (response.statusCode == 200) {
    final Map<String, dynamic> jsonResponse =
        Map<String, dynamic>.from(jsonDecode(utf8.decode(response.bodyBytes)));

    // 서버 응답 파싱
    String status = jsonResponse['sell_status'];
    int money = jsonResponse['user_money'];

    // 전역 변수 업데이트 (GUI 갱신)
    userMoney = money;
    isDataLoaded = true;

    print("판매 상태 : $status, 현재 골드 : $money");
    return 1;
  } else if (response.statusCode == 400) {
    final Map<String, dynamic> errorResponse =
        Map<String, dynamic>.from(jsonDecode(utf8.decode(response.bodyBytes)));

    print("판매 실패 : ${errorResponse['error_message']}");
    return 0;
  }
  return 0;
}

Future<int> loadUserMoney() async {
  String requestUrl = "http://localhost:8080/api/v1/user";
  final url = Uri.parse(requestUrl);

  String? token = getChromeAccessToken();
  String bearerToken = "Bearer $token";

  try {
    final response = await http.get(
      url,
      headers: {'Authorization': bearerToken},
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> jsonResponse =
          jsonDecode(utf8.decode(response.bodyBytes));
      return jsonResponse['money'] as int; // 서버에서 받은 money 값 반환
    } else {
      print('API 호출 실패: ${response.statusCode}');
      return -1; // 실패 시 -1 반환
    }
  } catch (e) {
    print('Error: $e');
    return -1; // 예외 발생 시 -1 반환
  }
}
