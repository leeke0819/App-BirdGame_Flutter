import 'dart:convert';
import 'package:bird_raise_app/config/env_config.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:http/http.dart' as http;
import 'package:bird_raise_app/token/chrome_token.dart';
import 'package:bird_raise_app/token/mobile_secure_token.dart';

class ApiBird {
  static final Uri _baseUrl = Uri.parse('${EnvConfig.apiUrl}/bird');

  static Future<Map<String, dynamic>?> feed(String itemCode, {int amount = 1}) async {
    String? token;
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
      final response = await http.post(
        Uri.parse('${_baseUrl}/feed'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json; charset=utf-8',
        },
        body: jsonEncode({
          'itemCode': itemCode,
          'amount': amount,
        }),
      );

      if (response.statusCode == 200) {
        print('✅ 아이템 사용 성공');
        final responseData = jsonDecode(utf8.decode(response.bodyBytes));
        print('서버 응답 데이터: $responseData');
        return responseData;
      } else {
        print('❌ 아이템 사용 실패: ${response.statusCode}');
        print('응답 내용: ${utf8.decode(response.bodyBytes)}');
        
        return null;
      }
    } catch (e) {
      print('❌ API 호출 중 오류 발생: $e');
      return null;
    }
  }
}