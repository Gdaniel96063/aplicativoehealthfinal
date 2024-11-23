import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  final String baseUrl;

  ApiService(this.baseUrl);

  Future<dynamic> fetchDNI(String token, String numero) async {
    final url = '$baseUrl/reniec/dni?numero=$numero';
    try {
      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        final errorResponse = json.decode(response.body);
        throw Exception('Error: ${errorResponse['message'] ?? response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error: $e');
    }
  }
}