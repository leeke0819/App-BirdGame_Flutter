import 'package:bird_raise_app/token/chrome_token.dart';
import 'package:http/http.dart' as http;

String baseUrl = "http://localhost:8080/api/v1/shop"; // Spring Boot 서버 주소

//사용자 아이템 구매하기
Future<int> buyItem(String itemCode) async {
  print("$itemCode구매 시도");
  String? token = getChromeAccessToken();
  String? bearerToken = "Bearer $token";
  final response = await http.post(
    Uri.parse("$baseUrl/buy?itemCode=$itemCode"),
    headers: {'Authorization': bearerToken}
    );
  if (response.statusCode == 200) {
    print("구매 성공");
    return 1;
  }else if(response.statusCode == 400){
    return 0;
  }
  return 0;
}

// Future<int> sellItem(String itemCode) async {
    //판매 만들기
// }