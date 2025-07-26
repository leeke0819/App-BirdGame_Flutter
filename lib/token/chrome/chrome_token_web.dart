// ignore: avoid_web_libraries_in_flutter
import 'dart:html';

void saveChromeAccessToken(String token){
  window.localStorage['accessToken'] = token;
}

String? getChromeAccessToken() {
  final accessToken = window.localStorage['accessToken'];
  if (accessToken == null || accessToken.isEmpty) {
    // accessToken이 없으면 refreshToken으로 재발급 시도
    final refreshToken = window.localStorage['refreshToken'];
    if (refreshToken != null && refreshToken.isNotEmpty) {
      // TODO: refreshToken을 사용해 accessToken을 재발급하는 로직을 구현해야 함
      // 예시: await fetchNewAccessToken(refreshToken);
      // 재발급 성공 시 window.localStorage['accessToken']에 저장 후 반환
      // 현재는 refreshToken이 있어도 null 반환
      print('accessToken이 없어 refreshToken으로 재발급 필요');
    }
    return null;
  }
  return accessToken;
}

void clearChromeAccessToken(){
  window.localStorage.remove('accessToken');
}
