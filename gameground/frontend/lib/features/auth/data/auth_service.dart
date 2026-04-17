import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:frontend/core/constants/api_constants.dart';

class AuthService {
  static String? _authToken;
  static int? _userId;
  static String? _userRole;
  static String? _username;
  static String? _email;

  static String? get token => _authToken;
  static int? get userId => _userId;
  static String? get role => _userRole;
  static String? get username => _username;
  static String? get email => _email;

  static Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    _authToken = prefs.getString('auth_token');
    _userId = prefs.getInt('user_id');
    _userRole = prefs.getString('user_role');
    _username = prefs.getString('username');
    _email = prefs.getString('email');
  }

  static Future<void> _saveSession(String token, int userId, String role, String username, String email) async {
    _authToken = token;
    _userId = userId;
    _userRole = role;
    _username = username;
    _email = email;

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('auth_token', token);
    await prefs.setInt('user_id', userId);
    await prefs.setString('user_role', role);
    await prefs.setString('username', username);
    await prefs.setString('email', email);
  }

  static Future<void> updateRole(String newRole) async {
    _userRole = newRole;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('user_role', newRole);
  }

  static Future<bool> login(String identifier, String password) async {
    try {
      final response = await http.post(
        Uri.parse('${ApiConstants.auth}/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'identifier': identifier, 'password': password}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final token = data['token'];
        final user = data['user'];
        await _saveSession(token, user['id'], user['role'], user['username'], user['email']);
        return true;
      }
      // If login fails, ensure we clear any stale tokens
      await logout();
      return false;
    } catch (e) {
      print("Login error: $e");
      await logout();
      return false;
    }
  }

  static Future<String?> register(String username, String email, String password, String role) async {
    try {
      print("Sending register request for: $username");
      final response = await http.post(
        Uri.parse('${ApiConstants.auth}/register'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'username': username,
          'email': email,
          'password': password,
          'role': role
        }),
      );
      print("Register response status: ${response.statusCode}");
      print("Register response body: ${response.body}");

      if (response.statusCode == 201) {
        final data = jsonDecode(response.body);
        final token = data['token'];
        final user = data['user'];
        await _saveSession(token, user['id'], user['role'], user['username'], user['email']);
        return null; // Success, no error message
      } else {
        await logout();
        final data = jsonDecode(response.body);
        return data['message'] ?? 'Registration failed';
      }
    } catch (e) {
      print("Register error: $e");
      await logout();
      return e.toString();
    }
  }

  static Future<void> logout() async {
    _userId = null;
    _authToken = null;
    _userRole = null;
    _username = null;
    _email = null;

    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }

  static Future<String?> forgotPassword(String email) async {
    try {
      final response = await http.post(
        Uri.parse('${ApiConstants.auth}/forgot-password'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email}),
      );

      if (response.statusCode == 200) {
        return null; // Success
      } else {
        final data = jsonDecode(response.body);
        return data['message'] ?? 'Failed to send OTP';
      }
    } catch (e) {
      print("Forgot password error: $e");
      return 'Network error occurred';
    }
  }

  static Future<String?> resetPassword(String email, String otp, String newPassword) async {
    try {
      final response = await http.post(
        Uri.parse('${ApiConstants.auth}/reset-password'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': email,
          'otp': otp,
          'newPassword': newPassword,
        }),
      );

      if (response.statusCode == 200) {
        return null; // Success
      } else {
        final data = jsonDecode(response.body);
        return data['message'] ?? 'Failed to reset password';
      }
    } catch (e) {
      print("Reset password error: $e");
      return 'Network error occurred';
    }
  }
}
