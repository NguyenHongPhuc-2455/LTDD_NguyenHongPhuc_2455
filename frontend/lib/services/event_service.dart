import 'dart:convert';
import 'package:http/http.dart' as http;
import 'auth_service.dart';

class EventService {
  Future<List<dynamic>> getEvents(String token) async {
    try {
      final response = await http.get(
        Uri.parse('${AuthService.baseUrl.replaceAll("/auth", "")}/events'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Failed to load events');
      }
    } catch (e) {
      throw Exception('Error: $e');
    }
  }

  Future<bool> createEvent(
    String token,
    String title,
    String description,
    DateTime startTime,
    DateTime endTime,
    int priorityId,
  ) async {
    try {
      // Format as local datetime string (YYYY-MM-DDTHH:mm:ss.000)
      final start =
          '${startTime.year}-${startTime.month.toString().padLeft(2, '0')}-${startTime.day.toString().padLeft(2, '0')}T${startTime.hour.toString().padLeft(2, '0')}:${startTime.minute.toString().padLeft(2, '0')}:${startTime.second.toString().padLeft(2, '0')}.000';
      final end =
          '${endTime.year}-${endTime.month.toString().padLeft(2, '0')}-${endTime.day.toString().padLeft(2, '0')}T${endTime.hour.toString().padLeft(2, '0')}:${endTime.minute.toString().padLeft(2, '0')}:${endTime.second.toString().padLeft(2, '0')}.000';

      final response = await http.post(
        Uri.parse('${AuthService.baseUrl.replaceAll("/auth", "")}/events'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'title': title,
          'description': description,
          'startTime': start,
          'endTime': end,
          'priorityId': priorityId,
        }),
      );

      return response.statusCode == 201;
    } catch (e) {
      return false;
    }
  }

  Future<bool> updateEvent(
    String token,
    int eventId,
    String title,
    String description,
    DateTime startTime,
    DateTime endTime,
    String status,
    int priorityId,
  ) async {
    try {
      // Format as local datetime string
      final start =
          '${startTime.year}-${startTime.month.toString().padLeft(2, '0')}-${startTime.day.toString().padLeft(2, '0')}T${startTime.hour.toString().padLeft(2, '0')}:${startTime.minute.toString().padLeft(2, '0')}:${startTime.second.toString().padLeft(2, '0')}.000';
      final end =
          '${endTime.year}-${endTime.month.toString().padLeft(2, '0')}-${endTime.day.toString().padLeft(2, '0')}T${endTime.hour.toString().padLeft(2, '0')}:${endTime.minute.toString().padLeft(2, '0')}:${endTime.second.toString().padLeft(2, '0')}.000';

      final response = await http.put(
        Uri.parse(
          '${AuthService.baseUrl.replaceAll("/auth", "")}/events/$eventId',
        ),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'title': title,
          'description': description,
          'startTime': start,
          'endTime': end,
          'status': status,
          'priorityId': priorityId,
        }),
      );

      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  Future<bool> deleteEvent(String token, int id) async {
    try {
      final response = await http.delete(
        Uri.parse('${AuthService.baseUrl.replaceAll("/auth", "")}/events/$id'),
        headers: {'Authorization': 'Bearer $token'},
      );

      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }
}
