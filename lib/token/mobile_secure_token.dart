import 'package:flutter_secure_storage/flutter_secure_storage.dart';

final FlutterSecureStorage secureStorage = FlutterSecureStorage();

// AccessToken 저장
Future<void> saveAccessToken(String accessToken) async {
  await secureStorage.write(key: 'accessToken', value: accessToken);
}

// AccessToken 가져와서 읽기
Future<String?> getAccessToken() async {
  return await secureStorage.read(key: 'accessToken');
}

// Token 삭제(로그아웃 할 때 사용)
Future<void> deleteTokens() async {
  await secureStorage.delete(key: 'accessToken');
}
