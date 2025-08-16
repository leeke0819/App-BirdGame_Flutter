import 'package:bird_raise_app/config/env_config.dart';
import 'package:bird_raise_app/main.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class NormalMembers extends StatefulWidget {
  const NormalMembers({super.key});

  @override
  _NormalMembersState createState() => _NormalMembersState();
}

class _NormalMembersState extends State<NormalMembers> {
  bool _obscurePassword = true; // 비밀번호 숨김 상태 변수
  final TextEditingController _passwordController =
      TextEditingController(); // 비밀번호 란 값
  final TextEditingController _confirmPasswordController =
      TextEditingController(); // 비밀번호 확인 란 값
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _nicknameController = TextEditingController();
  String? _errorMessage; // 비밀번호 확인 메시지

  void _validatePasswords() {
    // 비밀번호 일치하지 않으면 에러 메시지 표시
    setState(() {
      if (_passwordController.text != _confirmPasswordController.text) {
        _errorMessage = "비밀번호가 일치하지 않습니다.";
      } else {
        _errorMessage = null; // 에러 메시지 초기화
      }
    });
  }

  @override
  void dispose() {
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _emailController.dispose();
    _nicknameController.dispose();
    super.dispose();
  }

  Future<void> _register() async {
    final url = Uri.parse('${EnvConfig.apiUrl}/user');
    final Map<String, dynamic> data = {
      'nickname': _nicknameController.text,
      'email': _emailController.text,
      'password': _passwordController.text,
    };

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(data),
      );

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Registration successful!',
              style: TextStyle(fontFamily: 'NaverNanumSquareRound'),
            ),
          ),
        );
        // 로그인 성공 시 메인 페이지로 이동
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const LoginPage()),
        );
      } else {
        print("회원가입 실패");
        print(response.statusCode);
        print(response.body);
        final errorMessage = utf8.decode(response.bodyBytes); // 한글 깨짐 방지
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              errorMessage,
              style: const TextStyle(fontFamily: 'NaverNanumSquareRound'),
            ),
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Error: $e',
            style: const TextStyle(fontFamily: 'NaverNanumSquareRound'),
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.only(top: MediaQuery.of(context).size.height * 0.12), // 화면 높이의 10%
          child: Align(
            alignment: const Alignment(0, -0.3),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Transform.translate(
                  offset: const Offset(107, 0),
                  child: const Text(
                    '회원가입',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                      fontFamily: 'NaverNanumSquareRound',
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                const SizedBox(
                  width: 110,
                  height: 25,
                  child: Text(
                    '이메일',
                    textAlign: TextAlign.left,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                      fontFamily: 'NaverNanumSquareRound',
                    ),
                  ),
                ),
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
                        Expanded(
                          child: TextField(
                            controller: _emailController,
                            decoration: const InputDecoration(
                              hintText: '이메일 입력',
                              hintStyle: TextStyle(
                                color: Colors.grey,
                                fontFamily: 'NaverNanumSquareRound',
                              ),
                              border: InputBorder.none,
                            ),
                            style: const TextStyle(
                              fontSize: 16,
                              fontFamily: 'NaverNanumSquareRound',
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                const SizedBox(
                  width: 110,
                  height: 25,
                  child: Text(
                    '비밀번호',
                    textAlign: TextAlign.left,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                      fontFamily: 'NaverNanumSquareRound',
                    ),
                  ),
                ),
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
                        Expanded(
                          child: TextField(
                            controller: _passwordController,
                            obscureText: _obscurePassword,
                            decoration: InputDecoration(
                              hintText: '비밀번호 입력',
                              hintStyle: const TextStyle(
                                color: Colors.grey,
                                fontFamily: 'NaverNanumSquareRound',
                              ),
                              border: InputBorder.none,
                              suffixIcon: GestureDetector(
                                onTap: () {
                                  setState(() {
                                    _obscurePassword = !_obscurePassword;
                                  });
                                },
                                child: Icon(
                                  _obscurePassword
                                      ? Icons.visibility_off
                                      : Icons.visibility,
                                  color: Colors.grey,
                                ),
                              ),
                            ),
                            style: const TextStyle(
                              fontSize: 16,
                              fontFamily: 'NaverNanumSquareRound',
                            ),
                            onChanged: (_) => _validatePasswords(),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                const SizedBox(
                  width: 110,
                  height: 25,
                  child: Text(
                    '비밀번호 확인',
                    textAlign: TextAlign.left,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                      fontFamily: 'NaverNanumSquareRound',
                    ),
                  ),
                ),
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
                        Expanded(
                          child: TextField(
                            controller: _confirmPasswordController,
                            obscureText: true,
                            decoration: const InputDecoration(
                              hintText: '비밀번호 입력',
                              hintStyle: TextStyle(
                                color: Colors.grey,
                                fontFamily: 'NaverNanumSquareRound',
                              ),
                              border: InputBorder.none,
                            ),
                            style: const TextStyle(
                              fontSize: 16,
                              fontFamily: 'NaverNanumSquareRound',
                            ),
                            onChanged: (_) => _validatePasswords(),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                if (_errorMessage != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Text(
                      _errorMessage!,
                      style: const TextStyle(
                        color: Colors.red,
                        fontSize: 14,
                        fontFamily: 'NaverNanumSquareRound',
                      ),
                    ),
                  ),
                const SizedBox(height: 20),
                const SizedBox(
                  width: 110,
                  height: 25,
                  child: Text(
                    '닉네임',
                    textAlign: TextAlign.left,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                      fontFamily: 'NaverNanumSquareRound',
                    ),
                  ),
                ),
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
                        Expanded(
                          child: TextField(
                            controller: _nicknameController,
                            decoration: const InputDecoration(
                              hintText: '닉네임 입력',
                              hintStyle: TextStyle(
                                color: Colors.grey,
                                fontFamily: 'NaverNanumSquareRound',
                              ),
                              border: InputBorder.none,
                            ),
                            style: const TextStyle(
                              fontSize: 16,
                              fontFamily: 'NaverNanumSquareRound',
                            ),
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
                  child: InkWell(
                    onTap: () async {
                      await _register();
                    },
                    child: const Center(
                      child: Text(
                        '가입완료',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          fontFamily: 'NaverNanumSquareRound',
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
