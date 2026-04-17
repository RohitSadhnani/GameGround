import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:frontend/core/constants/api_constants.dart';
import 'package:frontend/features/auth/data/auth_service.dart';

class AdminService {
  static Future<Map<String, dynamic>?> getDashboardStats() async {
    try {
      final token = AuthService.token;
      if (token == null) return null;

      final response = await http.get(
        Uri.parse('${ApiConstants.baseUrl}/admin/stats'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      print('Admin Stats Response Status: ${response.statusCode}');
      print('Admin Stats Response Body: ${response.body}');

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
      return null;
    } catch (e) {
      print('Error fetching admin stats: $e');
      return null;
    }
  }

  static Future<List<dynamic>?> getOwnersList() async {
    try {
      final token = AuthService.token;
      if (token == null) return null;

      final response = await http.get(
        Uri.parse('${ApiConstants.baseUrl}/admin/owners'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body) as List<dynamic>;
      }
      return null;
    } catch (e) {
      print('Error fetching owners list: $e');
      return null;
    }
  }

  static Future<Map<String, dynamic>?> getOwnerStats(int ownerId) async {
    try {
      final token = AuthService.token;
      if (token == null) return null;

      final response = await http.get(
        Uri.parse('${ApiConstants.baseUrl}/admin/owners/$ownerId/stats'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
      return null;
    } catch (e) {
      print('Error fetching owner stats: $e');
      return null;
    }
  }

  static Future<List<dynamic>?> getExpiringSubscriptions() async {
    try {
      final token = AuthService.token;
      if (token == null) return null;

      final response = await http.get(
        Uri.parse('${ApiConstants.baseUrl}/admin/subscriptions/expiring'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body) as List<dynamic>;
      }
      return null;
    } catch (e) {
      print('Error fetching expiring subscriptions: $e');
      return null;
    }
  }

  // ===== Subscription Plan Management =====

  static Future<List<dynamic>?> getPlans() async {
    try {
      final token = AuthService.token;
      if (token == null) return null;

      final response = await http.get(
        Uri.parse('${ApiConstants.baseUrl}/admin/plans'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body) as List<dynamic>;
      }
      return null;
    } catch (e) {
      print('Error fetching plans: $e');
      return null;
    }
  }

  static Future<bool> createPlan(Map<String, dynamic> planData) async {
    try {
      final token = AuthService.token;
      if (token == null) return false;

      final response = await http.post(
        Uri.parse('${ApiConstants.baseUrl}/admin/plans'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(planData),
      );

      return response.statusCode == 201;
    } catch (e) {
      print('Error creating plan: $e');
      return false;
    }
  }

  static Future<bool> updatePlan(int id, Map<String, dynamic> planData) async {
    try {
      final token = AuthService.token;
      if (token == null) return false;

      final response = await http.put(
        Uri.parse('${ApiConstants.baseUrl}/admin/plans/$id'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(planData),
      );

      return response.statusCode == 200;
    } catch (e) {
      print('Error updating plan: $e');
      return false;
    }
  }

  static Future<bool> deletePlan(int id) async {
    try {
      final token = AuthService.token;
      if (token == null) return false;

      final response = await http.delete(
        Uri.parse('${ApiConstants.baseUrl}/admin/plans/$id'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      return response.statusCode == 200;
    } catch (e) {
      print('Error deleting plan: $e');
      return false;
    }
  }
}
