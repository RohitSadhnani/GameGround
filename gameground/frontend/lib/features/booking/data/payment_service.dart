import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:frontend/core/constants/api_constants.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PaymentService {

  static Future<void> payOnSpot({
    required int bookingId,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');

      final response = await http.post(
        Uri.parse('${ApiConstants.payments}/pay-on-spot'),
        headers: {
          'Content-Type': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'bookingId': bookingId,
        }),
      );

      if (response.statusCode != 200) {
         throw Exception(jsonDecode(response.body)['message'] ?? 'Pay on spot failed');
      }
    } catch (e) {
      throw Exception('Connection error: $e');
    }
  }

  static Future<void> payWithUpi({
    required int bookingId,
    required String upiId,
    required String pin,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');

      final response = await http.post(
        Uri.parse('${ApiConstants.payments}/pay-with-upi'),
        headers: {
          'Content-Type': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'bookingId': bookingId,
          'upiId': upiId,
          'pin': pin,
        }),
      );

      if (response.statusCode != 200) {
         throw Exception(jsonDecode(response.body)['message'] ?? 'UPI payment failed');
      }
    } catch (e) {
      throw Exception('Connection error: $e');
    }
  }
}
