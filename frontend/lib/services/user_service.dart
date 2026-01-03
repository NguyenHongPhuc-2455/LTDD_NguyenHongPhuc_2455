import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

class UserService {
  final String token;

  UserService(this.token);

  static String get baseUrl {
    if (kIsWeb) {
      return 'http://localhost:5000/api/users';
    } else if (Platform.isAndroid) {
      return 'http://10.0.2.2:5000/api/users';
    } else {
      return 'http://localhost:5000/api/users';
    }
  }

  Future<List<dynamic>> getUsers() async {
    final response = await http.get(
      Uri.parse(baseUrl),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to load users');
    }
  }

  Future<void> createUser(Map<String, dynamic> userData) async {
    final response = await http.post(
      Uri.parse(baseUrl),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode(userData),
    );

    if (response.statusCode != 201) {
      final msg =
          jsonDecode(response.body)['message'] ?? 'Failed to create user';
      throw Exception(msg);
    }
  }

  Future<void> updateUser(int id, Map<String, dynamic> userData) async {
    final response = await http.put(
      Uri.parse('$baseUrl/$id'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode(userData),
    );

    if (response.statusCode != 200) {
      final msg =
          jsonDecode(response.body)['message'] ?? 'Failed to update user';
      throw Exception(msg);
    }
  }

  Future<void> deleteUser(int id) async {
    final response = await http.delete(
      Uri.parse('$baseUrl/$id'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode != 200) {
      final msg =
          jsonDecode(response.body)['message'] ?? 'Failed to delete user';
      throw Exception(msg);
    }
  }
}
