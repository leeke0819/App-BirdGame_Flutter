// ignore: avoid_web_libraries_in_flutter
import 'dart:html';

void saveChromeAccessToken(String token){
  window.localStorage['accessToken'] = token;
}

String ?getChromeAccessToken(){
  return window.localStorage['accessToken'];
}

void clearChromeAccessToken(){
  window.localStorage.remove('accessToken');
}
