// lib/api/api_main.dart

import 'dart:convert';
import 'package:bird_raise_app/config/env_config.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:http/http.dart' as http;
import 'package:bird_raise_app/token/chrome_token.dart';
import 'package:bird_raise_app/token/mobile_secure_token.dart';

class ApiMain {
  static final Uri _userUrl = Uri.parse('${EnvConfig.apiUrl}/user');

  static Future<Map<String, dynamic>?> fetchUserInfo() async {
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
      final response = await http.get(
        _userUrl,
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        print('✅ 사용자 정보 조회 성공');
        final responseData = jsonDecode(utf8.decode(response.bodyBytes));
        print('서버 응답 데이터: $responseData');
        return responseData;
      }else if(response.statusCode == 401){
        print('❌ 토큰 만료');
        final responseData = jsonDecode(utf8.decode(response.bodyBytes));
        if (responseData is Map<String, dynamic> && responseData['status'] == 401 && responseData['error'] == 'ExpiredJwtException') {
          print('❌ 만료된 JWT 토큰: ${responseData['message']}');
          //TODO:: 토큰 재발급 로직 함수 호출
          return responseData;
        }
      }
       else {
        print('❌ 사용자 정보 호출 실패: ${response.statusCode}');
        print('응답 내용: ${utf8.decode(response.bodyBytes)}');
        return null;
      }
    } catch (e) {
      print('❌ API 호출 중 오류 발생: $e');
      return null;
    }
  }

  /// 로그아웃: 로컬 토큰 삭제
  static Future<void> logout() async {
    if (kIsWeb) {
      print("🌐 로그아웃 (웹): localStorage 삭제");
      clearChromeAccessToken();
    } else {
      print("📱 로그아웃 (모바일): secure storage 삭제");
      await deleteTokens();
    }
  }

  Future<Map<String, dynamic>?> feed(String itemCode) async {
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
    final response = await http.post(
      Uri.parse('${EnvConfig.apiUrl}/bird/feed'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'itemCode': itemCode,
        'amount': 1,
      }),
    );
    print(response.statusCode);

    if (response.statusCode == 200) {
      print('✅ 아이템 사용 성공');
      return jsonDecode(response.body);
    } else {
      print('❌ 아이템 사용 실패: ${response.statusCode}');
      return null;
    }
  }

  Future<void> loadNickname() async {
    String? token;
    if (kIsWeb) {
      token = getChromeAccessToken();
    } else {
      token = await getAccessToken();
    }
    if (token == null) {
      print('⚠️ 토큰이 없습니다.');
      return;
    }
    final response = await http.get(
      Uri.parse('${EnvConfig.apiUrl}/api/v1/user/nickname'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      print('✅ 닉네임 조회 성공');
      return jsonDecode(response.body);
    } else {
      print('❌ 닉네임 조회 실패: ${response.statusCode}');
      return;
    }
  }
}
