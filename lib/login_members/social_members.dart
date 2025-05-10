import 'package:flutter/material.dart';
import 'package:kakao_flutter_sdk/kakao_flutter_sdk.dart';

class SocialMembers extends StatefulWidget {
  const SocialMembers({super.key});

  @override
  State<SocialMembers> createState() => _SocialMembers();
}

Future<OAuthToken> kakaoLogin() async {
  try {
    print("카카오 로그인 시도");
    return await UserApi.instance
        .loginWithKakaoTalk(); // ios, android 카카오톡 로그인(앱 내부 로그인) 시도
  } catch (e) {
    // 로그인 시도가 실패하면? 카카오 로그인(아이디, 비번 직접 입력) 실행
    print("KakaoTalk로그인 실패 KakaoAccount 로그인 시도");
    try {
      return await UserApi.instance.loginWithKakaoAccount();
    } catch (error) {
      // 위의 예외처리에서도 실패할 경우
      print("실패: ${error}");
      await Future.delayed(const Duration(seconds: 1)); // 1초 딜레이 걸기
      return await UserApi.instance.loginWithKakaoAccount(); // 카카오 로그인 한번 더 시도
    }
  }
}

Future<void> kakaoLoadUserProfile() async {
  try {
    print("카카오 사용자 정보 요청 시도");
    User user = await UserApi.instance.me();
    print('카카오 사용자 정보 요청 성공'
        '\n닉네임: ${user.kakaoAccount?.profile?.nickname}'
        '\n프로필사진: ${user.kakaoAccount?.profile?.profileImageUrl}');
  } catch (error) {
    print('사용자 정보 요청 실패 $error');
  }
}

class _SocialMembers extends State<SocialMembers> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Center(
        child: Transform.translate(
          offset: const Offset(0, -50),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Transform.translate(
                offset: const Offset(-5, 0), // 위치 조정
                child: const Text(
                  '소셜회원가입',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                    fontFamily: 'NaverNanumSquareRound',
                  ),
                ),
              ),
              const SizedBox(height: 20),
              GestureDetector(
                onTap: () async {
                  print('카카오 로그인 버튼이 클릭되었습니다');
                  OAuthToken token = await kakaoLogin();
                  print(token);
                  await kakaoLoadUserProfile();
                },
                child: Image.asset(
                  'images/kakao_login_medium_wide.png',
                  fit: BoxFit.contain,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
