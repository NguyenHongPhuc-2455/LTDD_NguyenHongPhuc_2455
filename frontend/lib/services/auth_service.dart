import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

class AuthService {
  static String get baseUrl {
    if (kIsWeb) {
      return 'http://localhost:5000/api/auth';
    } else if (Platform.isAndroid) {
      return 'http://10.0.2.2:5000/api/auth';
    } else {
      return 'http://localhost:5000/api/auth';
    }
  }

  Future<Map<String, dynamic>> login(String username, String password) async {
    try {
      final url = '$baseUrl/login';
      print('\ud83d\udd35 LOGIN: $url');

      final response = await http.post(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'username': username, 'password': password}),
      );

      print('\ud83d\udd35 LOGIN Response: ${response.statusCode}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        // Check if OTP is required
        if (data['requiresOTP'] == true) {
          return {
            'success': true,
            'requiresOTP': true,
            'userId': data['userId'],
            'email': data['email'],
          };
        }
        return {'success': true, 'data': data};
      } else {
        final errorMsg =
            jsonDecode(response.body)['message'] ?? 'Unknown error';
        return {'success': false, 'message': errorMsg};
      }
    } catch (e) {
      return {'success': false, 'message': 'Connection error: $e'};
    }
  }

  Future<Map<String, dynamic>> register(
    String username,
    String password,
    String fullName,
    String role,
    String email,
  ) async {
    try {
      final url = '$baseUrl/register';
      print('\ud83d\udfe2 REGISTER: $url');

      final response = await http.post(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'username': username,
          'password': password,
          'fullName': fullName,
          'role': role,
          'email': email,
        }),
      );

      print('\ud83d\udfe2 REGISTER Response: ${response.statusCode}');

      if (response.statusCode == 201) {
        return {'success': true};
      } else {
        final errorMsg =
            jsonDecode(response.body)['message'] ?? 'Unknown error';
        return {'success': false, 'message': errorMsg};
      }
    } catch (e) {
      return {'success': false, 'message': 'Connection error: $e'};
    }
  }

  Future<Map<String, dynamic>> verifyOTP(int userId, String otpCode) async {
    try {
      final url = '$baseUrl/verify-otp';
      print('\u2705 VERIFY OTP: $url');

      final response = await http.post(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'userId': userId, 'otpCode': otpCode}),
      );

      print('\u2705 VERIFY OTP Response: ${response.statusCode}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return {
          'success': true,
          'data': {'token': data['token'], 'role': data['role']},
        };
      } else {
        final errorMsg = jsonDecode(response.body)['message'] ?? 'Invalid OTP';
        return {'success': false, 'message': errorMsg};
      }
    } catch (e) {
      return {'success': false, 'message': 'Connection error: $e'};
    }
  }
}
