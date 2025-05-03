import 'package:alice/alice.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

/// ApiInspector provides a singleton service for debugging API requests and responses
/// using the Alice package. This makes it possible for QA testers to access
/// detailed HTTP logs even in release builds.
class ApiInspector {
  static final ApiInspector _instance = ApiInspector._internal();
  late Alice _alice;
  bool _isInitialized = false;
  final Dio _dio = Dio();

  factory ApiInspector() {
    return _instance;
  }

  ApiInspector._internal();

  /// Initialize the API inspector with a navigator key
  /// This must be called before using the inspector
  void initialize({required GlobalKey<NavigatorState> navigatorKey}) {
    if (!_isInitialized) {
      _alice = Alice(
        navigatorKey: navigatorKey,
        showNotification: true,
        showInspectorOnShake: true,
        maxCallsCount: 1000,
      );
      
      // Configure Dio with Alice interceptor
      _dio.interceptors.add(_alice.getDioInterceptor());
      _isInitialized = true;
    }
  }

  /// Get an HTTP client that works with Alice
  http.Client getHttpClient() {
    return _AliceHttpClient(this);
  }

  /// Show the Alice inspector UI
  void showInspector() {
    if (_isInitialized) {
      _alice.showInspector();
    }
  }
  
  /// Used internally by the HTTP client to log requests via Dio/Alice
  Future<http.Response> processHttpRequest(
    String method,
    Uri url,
    Map<String, String> headers,
    String? body,
    Future<http.Response> Function() httpCall
  ) async {
    if (!_isInitialized) {
      return await httpCall();
    }

    try {
      // We'll use Dio to track the request with Alice, but actually execute with http
      final dioOptions = Options(
        method: method,
        headers: headers,
      );
      
      // Fire and forget - we use this just for logging
      _dio.request(
        url.toString(),
        data: body,
        options: dioOptions,
      ).catchError((e) {
        // Ignore errors in the tracking request
      });
      
      // Execute the actual HTTP request
      return await httpCall();
    } catch (e) {
      rethrow;
    }
  }
}

/// Custom HTTP client that logs all requests via Alice
class _AliceHttpClient extends http.BaseClient {
  final ApiInspector _inspector;
  final http.Client _client = http.Client();

  _AliceHttpClient(this._inspector);

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) async {
    if (request is http.Request) {
      // For regular requests with body
      final method = request.method;
      final url = request.url;
      final headers = request.headers;
      final body = request.body;
      
      // Create a copy of the request to send
      final requestCopy = http.Request(method, url)
        ..headers.addAll(headers)
        ..body = body;
      
      try {
        // Process the request and track with Dio/Alice
        final response = await _inspector.processHttpRequest(
          method, 
          url, 
          headers, 
          body, 
          () => _client.send(requestCopy).then((res) => http.Response.fromStream(res))
        );
        
        // Convert back to StreamedResponse
        return http.StreamedResponse(
          Stream.value(response.bodyBytes),
          response.statusCode,
          headers: response.headers,
          reasonPhrase: response.reasonPhrase,
          request: request,
        );
      } catch (e) {
        rethrow;
      }
    } else {
      // For other types of requests (multipart, etc.)
      // We'll still track them with Alice but with less detail
      final method = request.method;
      final url = request.url;
      final headers = request.headers;
      
      try {
        // Process the request and track with Dio/Alice 
        await _inspector.processHttpRequest(
          method, 
          url, 
          headers, 
          null, 
          () async => http.Response('', 200) // Dummy response for tracking only
        );
        
        // Actually send the original request
        return await _client.send(request);
      } catch (e) {
        rethrow;
      }
    }
  }
}
