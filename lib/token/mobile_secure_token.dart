import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:bird_raise_app/api/api_auth.dart';

final FlutterSecureStorage secureStorage = FlutterSecureStorage();

// AccessToken 저장
Future<void> saveAccessToken(String accessToken, String refreshToken) async {
  await secureStorage.write(key: 'accessToken', value: accessToken);
  await secureStorage.write(key: 'refreshToken', value: refreshToken);
}

// AccessToken만 저장
Future<void> saveAccessTokenOnly(String accessToken) async {
  await secureStorage.write(key: 'accessToken', value: accessToken);
}

// RefreshToken만 저장
Future<void> saveRefreshTokenOnly(String refreshToken) async {
  await secureStorage.write(key: 'refreshToken', value: refreshToken);
}

// AccessToken 가져와서 읽기 (자동 재발급 포함)
Future<String?> getAccessToken() async {
  String? accessToken = await secureStorage.read(key: 'accessToken');
  
  if (accessToken == null || accessToken.isEmpty) {
    // accessToken이 없으면 refreshToken으로 재발급 시도
    String? refreshToken = await secureStorage.read(key: 'refreshToken');
    if (refreshToken != null && refreshToken.isNotEmpty) {
      try {
        final newTokens = await ApiAuth.reissueToken(refreshToken);
        if (newTokens != null) {
          await saveAccessTokenOnly(newTokens['accessToken']);
          await saveRefreshTokenOnly(newTokens['refreshToken']);
          return newTokens['accessToken'];
        }
      } catch (e) {
        print('토큰 재발급 실패: $e');
        // 재발급 실패 시 모든 토큰 삭제
        await deleteAllTokens();
      }
    }
    return null;
  }
  return accessToken;
}

// RefreshToken 가져와서 읽기
Future<String?> getRefreshToken() async {
  return await secureStorage.read(key: 'refreshToken');
}

// AccessToken 삭제
Future<void> deleteAccessToken() async {
  await secureStorage.delete(key: 'accessToken');
}

// RefreshToken 삭제
Future<void> deleteRefreshToken() async {
  await secureStorage.delete(key: 'refreshToken');
}

// 모든 Token 삭제(로그아웃 할 때 사용)
Future<void> deleteAllTokens() async {
  await secureStorage.delete(key: 'accessToken');
  await secureStorage.delete(key: 'refreshToken');
}

// 기존 함수와의 호환성을 위한 래퍼
Future<void> deleteTokens() async {
  await deleteAllTokens();
}
