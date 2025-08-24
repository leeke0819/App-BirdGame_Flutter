import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:flutter/foundation.dart';
import 'package:bird_raise_app/api/api_auth.dart';
import 'package:bird_raise_app/main_page.dart';
import 'package:bird_raise_app/token/mobile_secure_token.dart';
import 'package:bird_raise_app/token/chrome_token.dart';

/// WebView를 사용한 카카오 로그인 페이지
class KakaoWebViewLoginPage extends StatefulWidget {
  const KakaoWebViewLoginPage({super.key});

  @override
  _KakaoWebViewLoginPageState createState() => _KakaoWebViewLoginPageState();
}

class _KakaoWebViewLoginPageState extends State<KakaoWebViewLoginPage> {
  late final WebViewController _controller;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onProgress: (int progress) {
            // 로딩 진행률 업데이트
          },
          onPageStarted: (String url) {
            setState(() {
              _isLoading = true;
            });
          },
          onPageFinished: (String url) {
            setState(() {
              _isLoading = false;
            });
          },
          onNavigationRequest: (NavigationRequest request) {
            // redirect_uri 가로채기
            if (request.url.startsWith('myapp://kakao/callback')) {
              _handleKakaoCallback(request.url);
              return NavigationDecision.prevent;
            }
            return NavigationDecision.navigate;
          },
        ),
      )
      ..loadRequest(Uri.parse(ApiAuth.getKakaoAuthUrl()));
  }

  /// 카카오 로그인 콜백 URL 처리
  void _handleKakaoCallback(String callbackUrl) async {
    try {
      // URL에서 인증 코드 추출
      final uri = Uri.parse(callbackUrl);
      final authCode = uri.queryParameters['code'];
      final state = uri.queryParameters['state'];
      
      if (authCode != null && state == 'xyz123') {
        print('카카오 인증 코드 추출 성공: $authCode');
        
        // Spring 서버에 인증 코드 전송하여 토큰 받기
        final tokenData = await ApiAuth.exchangeCodeForToken(authCode);
        
        print('카카오 로그인 성공: ${tokenData['accessToken']}');
        
        // 토큰 저장 (환경에 따라 다르게 처리)
        if (kIsWeb) {
          saveChromeAccessToken(
            tokenData['accessToken'], 
            tokenData['refreshToken']
          );
        } else {
          await saveAccessToken(
            tokenData['accessToken'], 
            tokenData['refreshToken']
          );
        }
        
        // 로그인 성공 후 메인 페이지로 이동
        Get.offAll(() => const MainPage());
        
      } else {
        print('인증 코드 추출 실패 또는 state 불일치');
        Get.snackbar(
          '카카오 로그인 실패',
          '인증 코드를 받지 못했습니다.',
          snackPosition: SnackPosition.TOP,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      print('카카오 콜백 처리 실패: $e');
      Get.snackbar(
        '카카오 로그인 실패',
        '로그인 처리 중 오류가 발생했습니다.',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('카카오 로그인'),
        backgroundColor: const Color(0xFFFEE500),
        foregroundColor: Colors.black,
      ),
      body: Stack(
        children: [
          WebViewWidget(controller: _controller),
          if (_isLoading)
            const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFFEE500)),
              ),
            ),
        ],
      ),
    );
  }
} 