// ignore: avoid_web_libraries_in_flutter
import 'dart:html';

import 'package:bird_raise_app/api/api_auth.dart';

void saveChromeAccessToken(String token,String refreshToken){
  window.localStorage['accessToken'] = token;
}

// 동기 함수로 유지 (기존 코드와의 호환성)
String? getChromeAccessToken() {
  final accessToken = window.localStorage['accessToken'];
  if (accessToken == null || accessToken.isEmpty) {
    // accessToken이 없으면 refreshToken으로 재발급 시도
    final refreshToken = window.localStorage['refreshToken'];
    if (refreshToken != null && refreshToken.isNotEmpty) {
      // 비동기로 토큰 재발급 시도 (별도 처리)
      _tryReissueTokenAsync(refreshToken);
      print('accessToken이 없어 refreshToken으로 재발급 시도 중...');
    }
    return null;
  }
  return accessToken;
}

// 비동기 토큰 재발급 함수
Future<void> _tryReissueTokenAsync(String refreshToken) async {
  try {
    final newTokens = await ApiAuth.reissueToken(refreshToken);
    if (newTokens != null) {
      saveChromeAccessToken(newTokens['accessToken'], newTokens['refreshToken']);
      print('토큰 재발급 성공');
    }
  } catch (e) {
    print('토큰 재발급 실패: $e');
    // 재발급 실패 시 모든 토큰 삭제
    clearChromeAllTokens();
  }
}

// Refresh Token 저장
void saveChromeRefreshToken(String token) {
  window.localStorage['refreshToken'] = token;
}

// Refresh Token 가져오기
String? getChromeRefreshToken() {
  return window.localStorage['refreshToken'];
}

// 모든 토큰 삭제
void clearChromeAllTokens() {
  clearChromeAccessToken();
  clearChromeRefreshToken();
}

void clearChromeAccessToken(){
  window.localStorage.remove('accessToken');
}

void clearChromeRefreshToken(){
  window.localStorage.remove('refreshToken');
}
