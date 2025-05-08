import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  static Future<Map<String, dynamic>> lookupByPhone(String phone) async {
    final uri = Uri.parse('\${Config.baseUrl}/lookup/phone?number=\$phone');
    final resp = await http.get(uri);
    if (resp.statusCode != 200) {
      throw Exception('API lookup failed: \${resp.statusCode}');
    }
    return json.decode(resp.body) as Map<String, dynamic>;
  }
}
