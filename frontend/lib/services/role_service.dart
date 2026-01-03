import 'dart:convert';
import 'package:http/http.dart' as http;
import 'auth_service.dart';

class RoleService {
  Future<List<dynamic>> getRoles(String token) async {
    try {
      final response = await http.get(
        Uri.parse('${AuthService.baseUrl.replaceAll("/auth", "")}/roles'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Failed to load roles');
      }
    } catch (e) {
      throw Exception('Error: $e');
    }
  }

  // Public method to get roles without authentication (for registration)
  Future<List<String>> getRolesPublic() async {
    try {
      final response = await http.get(
        Uri.parse('${AuthService.baseUrl.replaceAll("/auth", "")}/roles'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final List<dynamic> roles = jsonDecode(response.body);
        return roles.map((role) => role['RoleName'] as String).toList();
      } else {
        // Fallback to default roles if API fails
        return ['Admin', 'Khách hàng', 'Manager'];
      }
    } catch (e) {
      print('Error fetching roles: $e');
      // Fallback to default roles
      return ['Admin', 'Khách hàng', 'Manager'];
    }
  }

  Future<bool> createRole(String token, String roleName) async {
    try {
      final response = await http.post(
        Uri.parse('${AuthService.baseUrl.replaceAll("/auth", "")}/roles'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({'roleName': roleName}),
      );

      return response.statusCode == 201;
    } catch (e) {
      return false;
    }
  }

  Future<bool> updateRole(String token, int id, String roleName) async {
    try {
      final response = await http.put(
        Uri.parse('${AuthService.baseUrl.replaceAll("/auth", "")}/roles/$id'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({'roleName': roleName}),
      );

      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  Future<bool> deleteRole(String token, int id) async {
    try {
      final response = await http.delete(
        Uri.parse('${AuthService.baseUrl.replaceAll("/auth", "")}/roles/$id'),
        headers: {'Authorization': 'Bearer $token'},
      );

      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }
}
