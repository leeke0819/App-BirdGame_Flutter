import 'dart:convert';
import 'package:bird_raise_app/config/env_config.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:http/http.dart' as http;
import 'package:bird_raise_app/token/chrome_token.dart';
import 'package:bird_raise_app/token/mobile_secure_token.dart';

class ApiGame {
  static Future<String?> startGame(int gameId) async {
    String? token;
    final Uri _userUrl = Uri.parse('${EnvConfig.apiUrl}/game/start');

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
        _userUrl,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({'gameId': gameId}),
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['sessionId']?.toString();
      } else {
        print('❌ 서버 오류: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      print('❌ API 호출 중 오류 발생: $e');
      return null;
    }
  }

  static Future<Map<String, dynamic>?> gameOver(String sessionId) async {
    String? token;
    final Uri _overUrl = Uri.parse('${EnvConfig.apiUrl}/game/over');

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
        _overUrl,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'sessionId': sessionId,
        }),
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data;
      } else {
        print('❌ 서버 오류: ${response.statusCode}');
        print('❗ Response body: ${response.body}');
        return null;
      }
    } catch (e) {
      print('❌ API 호출 중 오류 발생: $e');
      return null;
    }
  }
}
