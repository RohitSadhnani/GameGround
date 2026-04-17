import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:frontend/core/constants/api_constants.dart';

class BookingService {
  static Future<Map<String, dynamic>> createBooking({
    required int venueId,
    required int userId,
    required String bookingDate,
    required String timeSlot,
    required double totalAmount,
  }) async {
    try {
      final response = await http.post(
        Uri.parse(ApiConstants.bookings),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'venueId': venueId,
          'userId': userId,
          'bookingDate': bookingDate,
          'timeSlot': timeSlot,
          'totalAmount': totalAmount,
        }),
      );

      if (response.statusCode == 201) {
        return jsonDecode(response.body);
      } else {
        throw Exception(jsonDecode(response.body)['message'] ?? 'Failed to create booking');
      }
    } catch (e) {
      throw Exception('Connection error: $e');
    }
  }

  static Future<List<dynamic>> getUserBookings(int userId) async {
    try {
      final response = await http.get(
        Uri.parse('${ApiConstants.bookings}/user/$userId'),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception(jsonDecode(response.body)['message'] ?? 'Failed to fetch bookings');
      }
    } catch (e) {
      throw Exception('Connection error: $e');
    }
  }

  static Future<List<String>> getBookedSlotsForVenue(int venueId, String date) async {
    try {
      final response = await http.get(
        Uri.parse('${ApiConstants.bookings}/venue/$venueId/date/$date'),
      );

      if (response.statusCode == 200) {
        List<dynamic> data = jsonDecode(response.body);
        return data.map((e) => e.toString()).toList();
      } else {
        throw Exception(jsonDecode(response.body)['message'] ?? 'Failed to fetch booked slots');
      }
    } catch (e) {
      throw Exception('Connection error: $e');
    }
  }
}

