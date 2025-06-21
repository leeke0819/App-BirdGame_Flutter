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
        final responseData = jsonDecode(utf8.decode(response.bodyBytes));
        return responseData;
      } else {
        print('❌ 아이템 사용 실패: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      print('❌ API 호출 중 오류 발생: $e');
      return null;
    }
  }

  /// 새의 현재 상태를 가져오는 함수
  static Future<Map<String, dynamic>?> getBirdState() async {
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
        Uri.parse('${_baseUrl}/state'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json; charset=utf-8',
        },
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(utf8.decode(response.bodyBytes));
        return responseData;
      } else {
        print('❌ 새 상태 조회 실패: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      print('❌ API 호출 중 오류 발생: $e');
      return null;
    }
  }

  /// 새가 생성된 이후 경과 시간을 계산하는 함수
  static Duration calculateBirdAge(String createdAtString) {
    try {
      // ISO 8601 형식의 문자열을 DateTime으로 파싱
      final createdAt = DateTime.parse(createdAtString);
      final now = DateTime.now();
      return now.difference(createdAt);
    } catch (e) {
      print('❌ 날짜 파싱 오류: $e');
      return Duration.zero;
    }
  }

  /// 새의 나이를 포맷된 문자열로 반환하는 함수
  static String formatBirdAge(String createdAtString) {
    final duration = calculateBirdAge(createdAtString);
    final days = duration.inDays;
    final hours = duration.inHours.remainder(24);
    final minutes = duration.inMinutes.remainder(60);
    
    if (days > 0) {
      return '${days}일 ${hours}시간 ${minutes}분';
    } else if (hours > 0) {
      return '${hours}시간 ${minutes}분';
    } else {
      return '${minutes}분';
    }
  }
}