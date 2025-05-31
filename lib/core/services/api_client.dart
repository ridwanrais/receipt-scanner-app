import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:receipt_scanner/core/services/logger.dart';
import 'api_inspector.dart';

class ApiResponse<T> {
  final T? data;
  final bool success;
  final String? message;
  final int statusCode;
  final String? rawBody; // Added for debugging purposes

  ApiResponse({
    this.data,
    required this.success,
    this.message,
    required this.statusCode,
    this.rawBody,
  });
}

class ApiClient {
  final String baseUrl;
  final http.Client _httpClient;
  final Logger _logger = Logger();

  ApiClient({required this.baseUrl, http.Client? httpClient})
    : _httpClient = httpClient ?? ApiInspector().getHttpClient();

  // GET request
  Future<ApiResponse<T>> get<T>(
    String endpoint, {
    Map<String, String>? headers,
    Map<String, dynamic>? queryParameters,
    T Function(Map<String, dynamic> json)? fromJson,
  }) async {
    try {
      _logger.info('ApiClient.get - Base URL: $baseUrl');
      final uri = Uri.parse('$baseUrl$endpoint').replace(
        queryParameters: queryParameters?.map(
          (key, value) => MapEntry(key, value?.toString()),
        ),
      );

      final response = await _httpClient.get(
        uri,
        headers: {'Accept': 'application/json', ...?headers},
      );

      return _processResponse(response, fromJson);
    } catch (e) {
      return ApiResponse(
        success: false,
        message: 'Network error: ${e.toString()}',
        statusCode: 500,
      );
    }
  }

  // POST request
  Future<ApiResponse<T>> post<T>(
    String endpoint, {
    Map<String, String>? headers,
    Object? body,
    T Function(Map<String, dynamic> json)? fromJson,
  }) async {
    try {
      _logger.info('ApiClient.post - Base URL: $baseUrl');
      final uri = Uri.parse('$baseUrl$endpoint');

      final response = await _httpClient.post(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          ...?headers,
        },
        body: body != null ? jsonEncode(body) : null,
      );

      return _processResponse(response, fromJson);
    } catch (e) {
      return ApiResponse(
        success: false,
        message: 'Network error: ${e.toString()}',
        statusCode: 500,
      );
    }
  }

  // POST multipart request (for file uploads)
  Future<ApiResponse<T>> postMultipart<T>(
    String endpoint, {
    required File file,
    required String fieldName,
    Map<String, String>? fields,
    T Function(Map<String, dynamic> json)? fromJson,
  }) async {
    try {
      _logger.info('ApiClient.postMultipart - Base URL: $baseUrl');
      final uri = Uri.parse('$baseUrl$endpoint');
      _logger.info('ApiClient.postMultipart - Starting request to: $uri');
      _logger.info('ApiClient.postMultipart - File path: ${file.path}');
      _logger.info(
        'ApiClient.postMultipart - File exists: ${await file.exists()}',
      );
      _logger.info(
        'ApiClient.postMultipart - File size: ${await file.length()} bytes',
      );

      // Create a multipart request
      final request = http.MultipartRequest('POST', uri);

      // Add file
      _logger.info('ApiClient.postMultipart - Adding file to request...');
      // Using a different approach to handle large files better
      final bytes = await file.readAsBytes();
      final filename = file.path.split("/").last;
      _logger.info('ApiClient.postMultipart - Preparing file: $filename');
      
      final multipartFile = http.MultipartFile.fromBytes(
        fieldName,
        bytes,
        filename: filename,
      );
      _logger.info(
        'ApiClient.postMultipart - MultipartFile created: ${bytes.length} bytes, filename: $filename',
      );
      request.files.add(multipartFile);

      // Add other fields if any
      if (fields != null) {
        request.fields.addAll(fields);
        _logger.info(
          'ApiClient.postMultipart - Added ${fields.length} fields to request',
        );
      }

      // Add headers
      // Note: Content-Type is automatically set by the HTTP client for multipart requests
      // with the correct boundary parameter, so we don't set it manually
      request.headers.addAll({'Accept': 'application/json'});
      _logger.info('ApiClient.postMultipart - Headers set, sending request...');

      _logger.info(
        'ApiClient.postMultipart - Sending request to: ${request.url}',
      );
      _logger.info(
        'ApiClient.postMultipart - Request headers: ${request.headers}',
      );

      // For Alice logging, we'll use the existing processHttpRequest method
      // This will log the request to Alice if it's enabled
      final inspector = ApiInspector();
      if (inspector.isEnabled) {
        _logger.info('ApiClient.postMultipart - Logging request to Alice');
        // Create a simple representation of the multipart request for logging
        final requestBody = 'Multipart request with file: ${file.path}';

        // Use the existing processHttpRequest method to log to Alice
        // This will log the request but not actually send it
        inspector.processHttpRequest(
          'POST',
          uri,
          request.headers,
          requestBody,
          () async => http.Response('', 200), // Dummy response for logging only
        );
      }

      // Send the request using the HTTP client
      final streamedResponse = await _httpClient.send(request);
      _logger.info(
        'ApiClient.postMultipart - Response status: ${streamedResponse.statusCode}',
      );
      _logger.info(
        'ApiClient.postMultipart - Response headers: ${streamedResponse.headers}',
      );

      final response = await http.Response.fromStream(streamedResponse);
      _logger.info(
        'ApiClient.postMultipart - Response body length: ${response.body.length}',
      );
      _logger.info(
        'ApiClient.postMultipart - Response body preview: ${response.body.length > 100 ? '${response.body.substring(0, 100)}...' : response.body}',
      );

      // For response logging to Alice, we'll directly use the proper http.Response method
      // without causing a double request
      if (inspector.isEnabled) {
        _logger.info('ApiClient.postMultipart - Logging response to Alice');
        try {
          // Get the Alice instance
          final alice = inspector.getAlice();
          
          // Use the onHttpResponse method which is designed for the http package
          // This won't make another HTTP request
          alice.onHttpResponse(response);
          
          _logger.info('ApiClient.postMultipart - Response logged to Alice');
        } catch (e) {
          _logger.error(
            'ApiClient.postMultipart - Failed to log response to Alice: $e',
          );
        }
      }

      final apiResponse = _processResponse(response, fromJson);
      _logger.info(
        'ApiClient.postMultipart - Processed response: success=${apiResponse.success}, message=${apiResponse.message}',
      );
      return apiResponse;
    } catch (e) {
      _logger.error('ApiClient.postMultipart - Exception: $e');
      return ApiResponse(
        success: false,
        message: 'Network error: ${e.toString()}',
        statusCode: 500,
      );
    }
  }

  // PUT request
  Future<ApiResponse<T>> put<T>(
    String endpoint, {
    Map<String, String>? headers,
    Object? body,
    T Function(Map<String, dynamic> json)? fromJson,
  }) async {
    try {
      final uri = Uri.parse('$baseUrl$endpoint');

      final response = await _httpClient.put(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          ...?headers,
        },
        body: body != null ? jsonEncode(body) : null,
      );

      return _processResponse(response, fromJson);
    } catch (e) {
      return ApiResponse(
        success: false,
        message: 'Network error: ${e.toString()}',
        statusCode: 500,
      );
    }
  }

  // DELETE request
  Future<ApiResponse<T>> delete<T>(
    String endpoint, {
    Map<String, String>? headers,
    T Function(Map<String, dynamic> json)? fromJson,
  }) async {
    try {
      final uri = Uri.parse('$baseUrl$endpoint');

      final response = await _httpClient.delete(
        uri,
        headers: {'Accept': 'application/json', ...?headers},
      );

      return _processResponse(response, fromJson);
    } catch (e) {
      return ApiResponse(
        success: false,
        message: 'Network error: ${e.toString()}',
        statusCode: 500,
      );
    }
  }

  // Process HTTP response
  ApiResponse<T> _processResponse<T>(
    http.Response response,
    T Function(Map<String, dynamic> json)? fromJson,
  ) {
    final statusCode = response.statusCode;
    final hasJson =
        response.headers['content-type']?.contains('application/json') ?? false;
    final rawBody = response.body; // Store raw body for debugging

    // No content response (e.g., 204 for delete operations)
    if (statusCode == 204) {
      return ApiResponse<T>(
        success: true,
        statusCode: statusCode,
        rawBody: rawBody,
      );
    }

    // Handle empty response
    if (rawBody.isEmpty) {
      return ApiResponse<T>(
        success: statusCode >= 200 && statusCode < 300,
        statusCode: statusCode,
        message: 'Empty response',
        rawBody: rawBody,
      );
    }

    try {
      // Check if response is JSON
      if (!hasJson) {
        return ApiResponse<T>(
          success: false,
          statusCode: statusCode,
          message:
              'Invalid response format: Expected JSON but received different content type',
          rawBody:
              rawBody.length > 100
                  ? '${rawBody.substring(0, 100)}...'
                  : rawBody,
        );
      }

      // Parse JSON response
      final Map<String, dynamic> jsonResponse = jsonDecode(rawBody);

      // Success response
      if (statusCode >= 200 && statusCode < 300) {
        if (fromJson != null) {
          final T convertedData = fromJson(jsonResponse);
          return ApiResponse<T>(
            success: true,
            statusCode: statusCode,
            data: convertedData,
            rawBody: rawBody,
          );
        } else {
          return ApiResponse<T>(
            success: true,
            statusCode: statusCode,
            rawBody: rawBody,
          );
        }
      }

      // Error response
      return ApiResponse<T>(
        success: false,
        statusCode: statusCode,
        message: jsonResponse['message'] ?? 'Unknown error',
        rawBody: rawBody,
      );
    } catch (e) {
      // Error parsing response
      return ApiResponse<T>(
        success: false,
        statusCode: statusCode,
        message: 'Error parsing response: ${e.toString()}',
        rawBody:
            rawBody.length > 100 ? '${rawBody.substring(0, 100)}...' : rawBody,
      );
    }
  }
}
