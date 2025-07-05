import 'dart:convert';
import 'package:bird_raise_app/config/env_config.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:http/http.dart' as http;
import 'package:bird_raise_app/token/chrome_token.dart';
import 'package:bird_raise_app/token/mobile_secure_token.dart';

class ApiBook {
  static final Uri _baseUrl = Uri.parse('${EnvConfig.apiUrl}/book');

  static Future<List<dynamic>?> getBookList() async {
    String? token;
    print("getBookList Called");

    if (kIsWeb) {
      token = getChromeAccessToken();
    } else {
      token = await getAccessToken();
    }
    if (token == null) {
      print('⚠️ 토큰이 없습니다.');
      return null;
    }

    try {
      final response = await http.get(
        Uri.parse('${_baseUrl}/get-list'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json; charset=utf-8',
        },
      );
      if (response.statusCode == 200) {
        final responseData = jsonDecode(utf8.decode(response.bodyBytes));
        return responseData as List<dynamic>;
      } else {
        print('❌ 도감 조회 실패: [${response.statusCode}m');
        return null;
      }
    } catch (e) {
      print('❌ API 호출 중 오류 발생: $e');
      return null;
    }
  }
}