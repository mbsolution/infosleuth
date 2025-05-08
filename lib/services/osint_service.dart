import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:file_picker/file_picker.dart';

/// Change this to your actual backend URL:
const _baseUrl = 'http://localhost:8081';

class OsintService {
  /// Send a text query to `/api/orchestrate` and return the `"response"` string.
  static Future<String> fetchResponse(String query) async {
    final uri = Uri.parse('$_baseUrl/api/orchestrate');
    final resp = await http.post(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'query': query}),
    );
    if (resp.statusCode != 200) {
      throw Exception('Error ${resp.statusCode} from server');
    }
    final Map<String, dynamic> j = jsonDecode(resp.body);
    if (j['response'] == null) {
      throw Exception('Unexpected format from server, "response" was null');
    }
    return j['response'] as String;
  }

  /// Send an image (picked via FilePicker) to `/api/search_image`.
  /// If the server returns a top-level `"result"` object, we pull that out.
  /// Otherwise we return the entire JSON blob, so you can see exactly what came back.
  static Future<Map<String, dynamic>> searchImage(
      PlatformFile imageFile) async {
    final uri = Uri.parse('$_baseUrl/api/search_image');
    final b64 = base64Encode(imageFile.bytes!);
    final resp = await http.post(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'type': 'image',
        'query': b64,
      }),
    );
    if (resp.statusCode != 200) {
      throw Exception('Error ${resp.statusCode} from server');
    }
    final Map<String, dynamic> j = jsonDecode(resp.body);

    // If there's a top-level "result" key that's a JSON object, return it
    if (j['result'] is Map<String, dynamic>) {
      return j['result'] as Map<String, dynamic>;
    }

    // Otherwise hand back the entire response so you can inspect it.
    return j;
  }
}
