class ApiConfig {
  // Base URL for API calls (without version)
  static const String baseUrl = 'https://api.receipt-scan.ridwan-dev.cloud';
  
  // API version
  static const String apiVersion = 'v1';
  
  // Full API URL with version
  static String get apiBaseUrl => '$baseUrl/$apiVersion';
  
  // API request timeout in seconds
  static const int timeout = 30;
  
  // Max file upload size (in bytes)
  static const int maxUploadSize = 10 * 1024 * 1024; // 10 MB
}
