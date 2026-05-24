/// Backend API configuration
class ApiConfig {
  ApiConfig._();

  /// Base URL for the Python backend.
  /// Use your laptop's network IP so both Chrome and phone can reach it.
  /// Change this if your IP changes.
  static const String baseUrl = 'http://172.20.10.9:5000';

  /// API endpoints
  static const String scanEndpoint = '$baseUrl/api/scan';
  static const String healthEndpoint = '$baseUrl/api/health';
  static const String latestEndpoint = '$baseUrl/api/latest';
}
