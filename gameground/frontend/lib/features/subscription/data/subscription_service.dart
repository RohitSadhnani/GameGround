import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:frontend/core/constants/api_constants.dart';
import 'package:frontend/features/auth/data/auth_service.dart';

class SubscriptionService {
  static Future<void> purchaseSubscription({
    required String planName,
    required double amount,
    required String paymentMethod,
    required int durationMonths,
  }) async {
    final token = AuthService.token;
    if (token == null) throw Exception('Not authenticated');

    final response = await http.post(
      Uri.parse('${ApiConstants.subscriptions}/purchase'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({
        'planName': planName,
        'amount': amount,
        'paymentMethod': paymentMethod,
        'durationMonths': durationMonths,
      }),
    );

    if (response.statusCode != 201) {
      final data = jsonDecode(response.body);
      throw Exception(data['message'] ?? 'Failed to purchase subscription');
    }
  }

  static Future<Map<String, dynamic>?> getMySubscription() async {
    final token = AuthService.token;
    if (token == null) throw Exception('Not authenticated');

    final response = await http.get(
      Uri.parse('${ApiConstants.subscriptions}/me'),
      headers: {
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data != null && data['id'] != null) {
        return data;
      }
      return null;
    } else {
      throw Exception('Failed to fetch subscription status');
    }
  }

  static Future<List<dynamic>> getAvailablePlans() async {
    try {
      final response = await http.get(
        Uri.parse('${ApiConstants.subscriptions}/plans'),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body) as List<dynamic>;
      }
      return [];
    } catch (e) {
      print('Error fetching plans: $e');
      return [];
    }
  }
}
