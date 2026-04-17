import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:frontend/core/constants/api_constants.dart';
import 'package:frontend/features/auth/data/auth_service.dart';

class CoachingService {
  static Future<List<dynamic>> getAllCoachings() async {
    try {
      final response = await http.get(Uri.parse(ApiConstants.coaching));

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception(jsonDecode(response.body)['message'] ?? 'Failed to fetch coachings');
      }
    } catch (e) {
      throw Exception('Connection error: $e');
    }
  }

  static Future<List<dynamic>> getMyCoachings() async {
    try {
      final String? token = AuthService.token;
      if (token == null) throw Exception('User is not authenticated');

      final response = await http.get(
        Uri.parse('${ApiConstants.coachingPayments}/my'),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception(jsonDecode(response.body)['message'] ?? 'Failed to fetch my coachings');
      }
    } catch (e) {
      throw Exception('Connection error: $e');
    }
  }

  static Future<Map<String, dynamic>> createCoaching(Map<String, dynamic> data) async {
    try {
      final String? token = AuthService.token;
      if (token == null) throw Exception('User is not authenticated');

      final response = await http.post(
        Uri.parse(ApiConstants.coaching),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(data),
      );

      if (response.statusCode == 201) {
        return jsonDecode(response.body);
      } else {
        throw Exception(jsonDecode(response.body)['message'] ?? 'Failed to create coaching session');
      }
    } catch (e) {
      throw Exception('Connection error: $e');
    }
  }

  static Future<Map<String, dynamic>> registerForCoaching(Map<String, dynamic> data) async {
    try {
      final String? token = AuthService.token;
      if (token == null) throw Exception('User is not authenticated');

      final response = await http.post(
        Uri.parse(ApiConstants.coachingPayments),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(data),
      );

      if (response.statusCode == 201) {
        return jsonDecode(response.body);
      } else {
        throw Exception(jsonDecode(response.body)['message'] ?? 'Failed to register for coaching session');
      }
    } catch (e) {
      throw Exception('Connection error: $e');
    }
  }
}
