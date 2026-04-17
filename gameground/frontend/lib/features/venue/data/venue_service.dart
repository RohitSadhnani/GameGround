import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:frontend/core/constants/api_constants.dart';
import 'package:frontend/features/auth/data/auth_service.dart';

class VenueService {
  static Future<List<dynamic>> getAllVenues() async {
    try {
      final response = await http.get(Uri.parse(ApiConstants.venues));

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception(jsonDecode(response.body)['message'] ?? 'Failed to fetch venues');
      }
    } catch (e) {
      throw Exception('Connection error: $e');
    }
  }

  static Future<List<dynamic>> getMyVenues(String token) async {
    try {
      final response = await http.get(
        Uri.parse('${ApiConstants.venues}/my'),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception(jsonDecode(response.body)['message'] ?? 'Failed to fetch my venues');
      }
    } catch (e) {
      throw Exception('Connection error: $e');
    }
  }

  static Future<Map<String, dynamic>> createVenue(Map<String, dynamic> data) async {
    try {
      final String? token = AuthService.token;
      if (token == null) {
        throw Exception('User is not authenticated');
      }

      final response = await http.post(
        Uri.parse(ApiConstants.venues),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(data),
      );

      if (response.statusCode == 201) {
        return jsonDecode(response.body);
      } else {
        throw Exception(jsonDecode(response.body)['message'] ?? 'Failed to create venue');
      }
    } catch (e) {
      throw Exception('Connection error: $e');
    }
  }

  static Future<void> deleteVenue(dynamic id) async {
    try {
      final String? token = AuthService.token;
      if (token == null) {
        throw Exception('User is not authenticated');
      }

      final response = await http.delete(
        Uri.parse('${ApiConstants.venues}/$id'),
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode != 200) {
        // Just checking for a non-error status
        throw Exception(jsonDecode(response.body)['message'] ?? 'Failed to delete venue');
      }
    } catch (e) {
      throw Exception('Connection error: $e');
    }
  }

  static Future<Map<String, dynamic>> updateVenue(dynamic id, Map<String, dynamic> data) async {
    try {
      final String? token = AuthService.token;
      if (token == null) {
        throw Exception('User is not authenticated');
      }

      final response = await http.put(
        Uri.parse('${ApiConstants.venues}/$id'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(data),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception(jsonDecode(response.body)['message'] ?? 'Failed to update venue');
      }
    } catch (e) {
      throw Exception('Connection error: $e');
    }
  }
}
