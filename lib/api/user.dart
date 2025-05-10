import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:bird_raise_app/token/chrome_token.dart';
import 'package:bird_raise_app/token/mobile_secure_token.dart';


String baseUrl = "http://3.27.57.243:8080/api/v1/user";

/// 현재 골드 가져오기
Future<int?> fetchUserGold() async {
  final url = Uri.parse('http://3.27.57.243:8080/api/v1/user/gold');

  String? token;
  if (kIsWeb) {
    token = getChromeAccessToken();
  } else {
    token = await getAccessToken();
  }
  String bearerToken = "Bearer $token";

  try {
    final response = await http.get(
      url,
      headers: {'Authorization': bearerToken},
    );

    if (response.statusCode == 200) {
      final responseData = jsonDecode(response.body);
      return responseData['gold']; // JSON 형태: { "gold": 40000 }
    } else {
      print('서버 응답 오류: ${response.statusCode}');
    }
  } catch (e) {
    print('Gold 가져오기 실패: $e');
  }
  return null;
} // 실패 시 null 반환