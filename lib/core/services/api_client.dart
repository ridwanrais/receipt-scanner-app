import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'http_logger.dart';

class ApiResponse<T> {
  final T? data;
  final bool success;
  final String? message;
  final int statusCode;

  ApiResponse({
    this.data,
    required this.success,
    this.message,
    required this.statusCode,
  });
}

class ApiClient {
  final String baseUrl;
  final http.Client _httpClient;

  ApiClient({
    required this.baseUrl,
    http.Client? httpClient,
  }) : _httpClient = httpClient ?? HttpLogger().getHttpClient();

  // GET request
  Future<ApiResponse<T>> get<T>(
    String endpoint, {
    Map<String, String>? headers,
    Map<String, dynamic>? queryParameters,
    T Function(Map<String, dynamic> json)? fromJson,
  }) async {
    try {
      final uri = Uri.parse('$baseUrl$endpoint').replace(
        queryParameters: queryParameters?.map(
          (key, value) => MapEntry(key, value?.toString()),
        ),
      );

      final response = await _httpClient.get(
        uri,
        headers: {
          'Accept': 'application/json',
          ...?headers,
        },
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
      final uri = Uri.parse('$baseUrl$endpoint');
      final request = http.MultipartRequest('POST', uri);
      
      // Add file
      request.files.add(await http.MultipartFile.fromPath(
        fieldName,
        file.path,
      ));
      
      // Add other fields if any
      if (fields != null) {
        request.fields.addAll(fields);
      }
      
      // Add headers
      request.headers.addAll({
        'Accept': 'application/json',
      });
      
      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);
      
      return _processResponse(response, fromJson);
    } catch (e) {
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
        headers: {
          'Accept': 'application/json',
          ...?headers,
        },
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
    final hasJson = response.headers['content-type']?.contains('application/json') ?? false;
    
    // No content response (e.g., 204 for delete operations)
    if (statusCode == 204) {
      return ApiResponse<T>(
        success: true,
        statusCode: statusCode,
      );
    }
    
    // Handle empty response
    if (response.body.isEmpty) {
      return ApiResponse<T>(
        success: statusCode >= 200 && statusCode < 300,
        statusCode: statusCode,
        message: 'Empty response',
      );
    }
    
    try {
      // Parse JSON response
      final Map<String, dynamic> jsonResponse = jsonDecode(response.body);
      
      // Success response
      if (statusCode >= 200 && statusCode < 300) {
        if (fromJson != null) {
          final T convertedData = fromJson(jsonResponse);
          return ApiResponse<T>(
            success: true,
            statusCode: statusCode,
            data: convertedData,
          );
        } else {
          return ApiResponse<T>(
            success: true,
            statusCode: statusCode,
          );
        }
      }
      
      // Error response
      return ApiResponse<T>(
        success: false,
        statusCode: statusCode,
        message: jsonResponse['message'] ?? 'Unknown error',
      );
    } catch (e) {
      // Error parsing response
      return ApiResponse<T>(
        success: false,
        statusCode: statusCode,
        message: 'Error parsing response: ${e.toString()}',
      );
    }
  }
}
