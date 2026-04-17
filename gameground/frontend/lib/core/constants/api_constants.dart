class ApiConstants {
  // Use the computer's local IP address so devices on the same WiFi can access the backend
  static const String baseUrl = 'http://10.212.153.82:5000/api';
  // Base URL for serving static files (images)
  static const String imageBaseUrl = 'http://10.212.153.82:5000';
  static const String venues = '$baseUrl/venues';
  static const String bookings = '$baseUrl/bookings';
  static const String payments = '$baseUrl/payments';
  static const String auth = '$baseUrl/auth';
  static const String coaching = '$baseUrl/coaching';
  static const String coachingPayments = '$baseUrl/coaching-payments';
  static const String subscriptions = '$baseUrl/subscriptions';
}
