import 'dart:convert';

import 'package:bird_raise_app/config/env_config.dart';
import 'package:bird_raise_app/model/gold_model.dart';
import 'package:bird_raise_app/token/chrome_token.dart';
import 'package:flutter/widgets.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:bird_raise_app/token/mobile_secure_token.dart';
import 'package:provider/provider.dart';

String baseUrl = "${EnvConfig.apiUrl}/shop";
int userGold = 0;
bool isDataLoaded = false;

//사용자 아이템 구매하기
Future<int> buyItem(String itemCode, BuildContext context) async {
  print("$itemCode구매 시도");
  String? token;
  if (kIsWeb) {
    token = getChromeAccessToken();
  } else {
    token = await getAccessToken(); //1초짜리 print문
  }
  String? bearerToken = "Bearer $token";

  final response = await http.post(Uri.parse("$baseUrl/buy?itemCode=$itemCode"),
      headers: {'Authorization': bearerToken});

  if (response.statusCode == 200) {
    final Map<String, dynamic> jsonResponse =
        Map<String, dynamic>.from(jsonDecode(utf8.decode(response.bodyBytes)));

    // 서버 응답 파싱
    String status = jsonResponse['buy_status'];
    int gold = jsonResponse['user_gold'];

    // 전역 변수 업데이트 (GUI 갱신)
    context.read<GoldModel>().updateGold(gold);

    print("구매 상태 : $status, 현재 골드 : $gold");
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
Future<int> sellItem(String itemCode, BuildContext context) async {
  print("$itemCode판매 시도");
  String? token;
  if (kIsWeb) {
    token = getChromeAccessToken();
  } else {
    token = await getAccessToken(); //1초짜리 print문
  }
  String? bearerToken = "Bearer $token";

  final response = await http.post(
      Uri.parse("$baseUrl/sell?itemCode=$itemCode"),
      headers: {'Authorization': bearerToken});

  if (response.statusCode == 200) {
    final Map<String, dynamic> jsonResponse =
        Map<String, dynamic>.from(jsonDecode(utf8.decode(response.bodyBytes)));

    // 서버 응답 파싱
    String status = jsonResponse['sell_status'];
    int gold = jsonResponse['user_gold'];

    // 전역 변수 업데이트 (GUI 갱신)
    context.read<GoldModel>().updateGold(gold);

    print("판매 상태 : $status, 현재 골드 : $gold");
    return 1;
  } else if (response.statusCode == 400) {
    final Map<String, dynamic> errorResponse =
        Map<String, dynamic>.from(jsonDecode(utf8.decode(response.bodyBytes)));

    print("판매 실패 : ${errorResponse['error_message']}");
    return 0;
  }
  return 0;
}

Future<Map<String, dynamic>?> loadUserInfo() async {
  String requestUrl = "${EnvConfig.apiUrl}/user";
  final url = Uri.parse(requestUrl);
  String? token;
  if (kIsWeb) {
    token = getChromeAccessToken();
  } else {
    token = await getAccessToken(); //1초짜리 print문
  }
  String bearerToken = "Bearer $token";

  try {
    final response = await http.get(
      url,
      headers: {'Authorization': bearerToken},
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> jsonResponse =
          jsonDecode(utf8.decode(response.bodyBytes));
      return jsonResponse;
    } else {
      print('API 호출 실패: ${response.statusCode}');
      return null;
    }
  } catch (e) {
    print('Error: $e');
    return null;
  }
}
