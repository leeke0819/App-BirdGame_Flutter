//TODO:: REISSUE TOKEN Refresh -> Access

import 'dart:convert';

import 'package:http/http.dart' as http;

class ApiAuth {
  static const String _baseUrl = 'http://localhost:8080';
  static const String _authUrl = '$_baseUrl/api/auth';

  static Future<Map<String, dynamic>> reissueToken(String refreshToken) async {
    try {
      final response = await http.post(
        Uri.parse('$_authUrl/reissue'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $refreshToken',
        },
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        
        // 응답 데이터 검증
        if (responseData.containsKey('accessToken') && 
            responseData.containsKey('refreshToken')) {
          return responseData;
        } else {
          throw Exception('토큰 재발급 응답 형식이 올바르지 않습니다');
        }
      } else if (response.statusCode == 401) {
        throw Exception('리프레시 토큰이 만료되었습니다. 다시 로그인해주세요.');
      } else if (response.statusCode == 400) {
        throw Exception('잘못된 리프레시 토큰입니다.');
      } else {
        throw Exception('토큰 재발급 실패: ${response.statusCode}');
      }
    } catch (e) {
      if (e is FormatException) {
        throw Exception('서버 응답 형식이 올바르지 않습니다.');
      }
      rethrow;
    }
  }

  static Future<Map<String, dynamic>> login(String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$_authUrl/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email, 'password': password}),
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        
        // 응답 데이터 검증
        if (responseData.containsKey('accessToken') && 
            responseData.containsKey('refreshToken')) {
          return responseData;
        } else {
          throw Exception('로그인 응답 형식이 올바르지 않습니다');
        }
      } else if (response.statusCode == 401) {
        throw Exception('이메일 또는 비밀번호가 올바르지 않습니다.');
      } else {
        throw Exception('로그인 실패: ${response.statusCode}');
      }
    } catch (e) {
      if (e is FormatException) {
        throw Exception('서버 응답 형식이 올바르지 않습니다.');
      }
      rethrow;
    }
  }

  static Future<Map<String, dynamic>> signup(String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$_authUrl/signup'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email, 'password': password}),
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        return responseData;
      } else if (response.statusCode == 409) {
        throw Exception('이미 존재하는 이메일입니다.');
      } else if (response.statusCode == 400) {
        throw Exception('잘못된 이메일 또는 비밀번호 형식입니다.');
      } else {
        throw Exception('회원가입 실패: ${response.statusCode}');
      }
    } catch (e) {
      if (e is FormatException) {
        throw Exception('서버 응답 형식이 올바르지 않습니다.');
      }
      rethrow;
    }
  }
}
