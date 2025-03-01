import 'package:http/http.dart' as http;
import 'dart:convert';

class GoldService {
  static const String baseUrl = "http://localhost:8080/api/v1/user"; // Spring Boot 서버 주소

  /// 현재 골드 가져오기
  static Future<int?> getMoney() async {
    final response = await http.get(Uri.parse(baseUrl));
    if (response.statusCode == 200) {
      return int.tryParse(response.body);
    } else {
      return null;
    }
  }
}