import 'package:bird_raise_app/config/env_config.dart';
import 'package:bird_raise_app/login_members/social_members.dart';
import 'package:bird_raise_app/model/gold_model.dart';
import 'package:bird_raise_app/token/mobile_secure_token.dart';
import 'package:bird_raise_app/token/chrome_token.dart';
import 'package:bird_raise_app/login_members/main_page.dart';
import 'package:bird_raise_app/login_members/normal_members.dart';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:kakao_flutter_sdk/kakao_flutter_sdk.dart';
import 'package:provider/provider.dart'; //웹 환경구분을 위한 import
import 'package:flutter_dotenv/flutter_dotenv.dart'; //환경변수 등록용

void main() async {
  await dotenv.load(fileName: ".env");
  WidgetsFlutterBinding.ensureInitialized();

  // 저장된 토큰 확인
  String? token;
  if (kIsWeb) {
    token = getChromeAccessToken();
  } else {
    token = await getAccessToken();
  }

  //카카오 로그인
  KakaoSdk.init(
    nativeAppKey: '20c7d3f66691c7dc19454411cd6a8751',
    javaScriptAppKey: 'd85aa4100c1fd9fe52a7414e8a8493c3',
  );

  runApp(MultiProvider(
    providers: [
      ChangeNotifierProvider(create: (_) => GoldModel()),
    ],
    child: GetMaterialApp(
        debugShowCheckedModeBanner: false,
        home: token != null ? const MainPage() : const LoginPage(),
        theme: ThemeData(
          fontFamily: 'NaverNanumSquareRound',
        )),
  ));
}

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  bool _obscurePassword = true; // 비밀번호 숨김 여부를 관리하는 상태 변수
  final TextEditingController _emailController =
      TextEditingController(text: 'test123@naver.com');
  final TextEditingController _passwordController =
      TextEditingController(text: '123Time^^');

  Future<void> _login() async {
    final url = Uri.parse('${EnvConfig.apiUrl}/user/login');
    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': _emailController.text,
          'password': _passwordController.text,
        }),
      );

      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 200) {
        Map<String, dynamic> responseData = json.decode(response.body);
        //환경구분 필요
        if (kIsWeb) {
          print("웹 환경에서 동작하는 코드");
          saveChromeAccessToken(responseData['accessToken']);
          print(getChromeAccessToken());
        } else {
          print("모바일 환경에서 동작하는 코드"); //얘가 먼저 실행
          await saveAccessToken(responseData['accessToken']); //3초정도 걸린다 가정.
          print(getAccessToken()); //1초짜리 print문
        }

        // 로그인 성공
        Get.offAll(() => const MainPage());
      } else {
        // 로그인 실패
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('로그인에 실패했습니다.')),
        );
      }
    } catch (e) {
      print('Error: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('서버 연결에 실패했습니다.')),
      );
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          fontFamily: 'NaverNanumSquareRound',
        ),
        home: Scaffold(
          appBar: AppBar(),
          body: Center(
            child: Align(
              alignment: const Alignment(0.0, 0.2),
              child: Transform.translate(
                offset: const Offset(-10, -90),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      '로그인',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(height: 20),
                    Container(
                      width: 300,
                      height: 50,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(7),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.person,
                              size: 24,
                              color: Colors.grey,
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: TextField(
                                controller: _emailController,
                                decoration: const InputDecoration(
                                  hintText: '이메일 입력',
                                  hintStyle: TextStyle(color: Colors.grey),
                                  border: InputBorder.none,
                                ),
                                style: const TextStyle(fontSize: 16),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Container(
                      width: 300,
                      height: 50,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(7),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.lock_rounded,
                              size: 24,
                              color: Colors.grey,
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: TextField(
                                controller: _passwordController,
                                obscureText: _obscurePassword,
                                decoration: InputDecoration(
                                  hintText: '비밀번호 입력',
                                  hintStyle:
                                      const TextStyle(color: Colors.grey),
                                  border: InputBorder.none,
                                  suffixIcon: GestureDetector(
                                    onTap: () {
                                      setState(() {
                                        _obscurePassword =
                                            !_obscurePassword; // 상태 반전
                                      });
                                    },
                                    child: Icon(
                                      _obscurePassword
                                          ? Icons.visibility_off // 숨김 상태 아이콘
                                          : Icons.visibility, // 보임 상태 아이콘
                                      color: Colors.grey,
                                    ),
                                  ),
                                ),
                                style: const TextStyle(fontSize: 16),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Container(
                      width: 300,
                      height: 50,
                      decoration: BoxDecoration(
                        color: Colors.purple,
                        borderRadius: BorderRadius.circular(7),
                      ),
                      child: GestureDetector(
                        onTap: _login,
                        child: const Center(
                          child: Text(
                            '로그인',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        GestureDetector(
                          onTap: () {
                            Get.to(() => const SocialMembers());
                          },
                          child: const Text(
                            'SNS 계정으로 로그인',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.grey,
                            ),
                          ),
                        ),
                        const SizedBox(width: 20),
                        GestureDetector(
                          onTap: () {
                            Get.to(() => const NormalMembers());
                          },
                          child: const Text(
                            '회원가입',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.grey,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ));
  }
}
