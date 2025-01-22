import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class NomalMembers extends StatefulWidget {
  const NomalMembers({super.key});

  @override
  _NomalMembersState createState() => _NomalMembersState();
}

class _NomalMembersState extends State<NomalMembers> {
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
    super.dispose();
  }

  Future<void> _register() async {
    final url = Uri.parse('http://localhost:8080/api/v1/user');
    final Map<String, dynamic> data = {
      'nickname': "가나다라마바",
      'email': "example11@naver.com",
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
          SnackBar(content: Text('Registration successful!')),
        );
        // 로그인 페이지로 이동
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Registration failed: ${response.body}')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Align(
        alignment: const Alignment(0, -0.3),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Transform.translate(
              offset: const Offset(107, 0), // 위치 조정
              child: const Text(
                '회원가입',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
            ),
            const SizedBox(height: 20),
            const SizedBox(
              width: 110, // 원하는 너비
              height: 25,
              child: Text(
                '이메일',
                textAlign: TextAlign.left,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
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
              child: const Padding(
                padding: EdgeInsets.symmetric(horizontal: 12),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        decoration: InputDecoration(
                          hintText: '이메일 입력',
                          hintStyle: TextStyle(color: Colors.grey),
                          border: InputBorder.none,
                        ),
                        style: TextStyle(fontSize: 16),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            const SizedBox(
              width: 110, // 원하는 너비
              height: 25,
              child: Text(
                '비밀번호',
                textAlign: TextAlign.left,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
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
                        obscureText: _obscurePassword, // 상태 변수로 제어
                        decoration: InputDecoration(
                          hintText: '비밀번호 입력',
                          hintStyle: const TextStyle(color: Colors.grey),
                          border: InputBorder.none,
                          suffixIcon: GestureDetector(
                            onTap: () {
                              setState(() {
                                _obscurePassword = !_obscurePassword; // 상태 반전
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
                        onChanged: (_) => _validatePasswords(), // 비밀번호 변경 시 확인
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            const SizedBox(
              width: 110, // 원하는 너비
              height: 25,
              child: Text(
                '비밀번호 확인',
                textAlign: TextAlign.left,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
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
                          hintStyle: TextStyle(color: Colors.grey),
                          border: InputBorder.none,
                        ),
                        style: const TextStyle(fontSize: 16),
                        onChanged: (_) => _validatePasswords(), // 확인 필드 변경 시 검증
                      ),
                    ),
                  ],
                ),
              ),
            ),
            if (_errorMessage != null) // 에러 메시지가 있을 경우 표시
              Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Text(
                  _errorMessage!,
                  style: const TextStyle(color: Colors.red, fontSize: 14),
                ),
              ),
            const SizedBox(height: 20),
            const SizedBox(
              width: 110, // 원하는 너비
              height: 25,
              child: Text(
                '닉네임',
                textAlign: TextAlign.left,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
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
              child: const Padding(
                padding: EdgeInsets.symmetric(horizontal: 12),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        decoration: InputDecoration(
                          hintText: '닉네임 입력',
                          hintStyle: TextStyle(color: Colors.grey),
                          border: InputBorder.none,
                        ),
                        style: TextStyle(fontSize: 16),
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
                  // 가입 완료 버튼 클릭 시 _register 메서드 호출
                  await _register();
                },
                child: const Center(
                  child: Text(
                    '가입완료',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
