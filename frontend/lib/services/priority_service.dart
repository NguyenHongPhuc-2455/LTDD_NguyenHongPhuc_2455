import 'dart:convert';
import 'package:http/http.dart' as http;
import 'auth_service.dart';

class PriorityService {
  Future<List<dynamic>> getPriorities(String token) async {
    try {
      final response = await http.get(
        Uri.parse('${AuthService.baseUrl.replaceAll("/auth", "")}/priorities'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Failed to load priorities');
      }
    } catch (e) {
      throw Exception('Error: $e');
    }
  }
}
