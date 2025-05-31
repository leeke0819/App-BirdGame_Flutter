// lib/api/api_bag.dart

import 'dart:convert';
import 'package:bird_raise_app/config/env_config.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:http/http.dart' as http;
import 'package:bird_raise_app/token/chrome_token.dart';
import 'package:bird_raise_app/token/mobile_secure_token.dart';

Future<List<Map<String, String>>> fetchBagData({int page = 0}) async {
  print("fetchData");
  final url = Uri.parse("${EnvConfig.apiUrl}/bag/page?pageNo=$page");

  String? token = kIsWeb ? getChromeAccessToken() : await getAccessToken();
  if (token == null) throw Exception("Token is null");

  final response = await http.get(
    url,
    headers: {'Authorization': 'Bearer $token'},
  );

  if (response.statusCode == 200) {
    print("200");
    final List<dynamic> jsonResponse =
        jsonDecode(utf8.decode(response.bodyBytes));

    final filteredItems =
        jsonResponse.where((item) => item['amount'] > 0).toList();

    return filteredItems.map((item) {
      final entity = item['itemEntity'];
      return {
        'imagePath': entity['imageRoot'].toString(),
        'itemName': entity['itemName'].toString(),
        'itemDescription': entity['itemDescription'].toString(),
        'amount': item['amount'].toString(),
        'itemCode': entity['itemCode'].toString(),
      };
    }).toList();
  } else {
    throw Exception("API 호출 실패: ${response.statusCode}");
  }
}
