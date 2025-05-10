import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

/// A custom HTTP client that logs all requests and responses
class LoggingHttpClient extends http.BaseClient {
  final http.Client _inner;
  final bool Function()? _shouldLog;
  
  /// Creates a logging HTTP client
  /// 
  /// [shouldLog] - Optional function that determines if logging is enabled
  LoggingHttpClient({
    http.Client? innerClient,
    bool Function()? shouldLog,
  }) : 
    _inner = innerClient ?? http.Client(),
    _shouldLog = shouldLog;

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) async {
    final shouldLog = _shouldLog?.call() ?? true;
    
    if (shouldLog) {
      // Log request
      _logRequest(request);
    }
    
    // Forward the request to the inner client
    final response = await _inner.send(request);
    
    if (shouldLog) {
      // Log response
      _logResponse(response);
    }
    
    // Return a copy of the response with a fresh stream
    return http.StreamedResponse(
      response.stream.asBroadcastStream(),
      response.statusCode,
      contentLength: response.contentLength,
      request: response.request,
      headers: response.headers,
      isRedirect: response.isRedirect,
      persistentConnection: response.persistentConnection,
      reasonPhrase: response.reasonPhrase,
    );
  }
  
  void _logRequest(http.BaseRequest request) {
    final method = request.method;
    final url = request.url.toString();
    final headers = request.headers;
    
    final buffer = StringBuffer();
    buffer.writeln('┌────── Request ──────');
    buffer.writeln('$method $url');
    
    // Log headers
    headers.forEach((name, value) {
      buffer.writeln('$name: $value');
    });
    
    // Log body for appropriate request types
    if (request is http.Request) {
      final body = request.body;
      if (body.isNotEmpty) {
        buffer.writeln('\nBody:');
        try {
          // Try to format JSON
          final json = jsonDecode(body);
          buffer.writeln(const JsonEncoder.withIndent('  ').convert(json));
        } catch (_) {
          // If not JSON, log as-is
          buffer.writeln(body);
        }
      }
    }
    
    buffer.writeln('└───────────────────');
    debugPrint(buffer.toString());
  }
  
  void _logResponse(http.StreamedResponse response) async {
    final statusCode = response.statusCode;
    final reasonPhrase = response.reasonPhrase;
    final headers = response.headers;
    
    final buffer = StringBuffer();
    buffer.writeln('┌────── Response ──────');
    buffer.writeln('Status: $statusCode ${reasonPhrase ?? ""}');
    
    // Log headers
    headers.forEach((name, value) {
      buffer.writeln('$name: $value');
    });
    
    // Collect the response body
    final bodyBytes = await response.stream.toBytes();
    if (bodyBytes.isNotEmpty) {
      final contentType = headers['content-type'] ?? '';
      buffer.writeln('\nBody:');
      
      // Handle different content types
      if (contentType.contains('application/json')) {
        try {
          final json = jsonDecode(utf8.decode(bodyBytes));
          buffer.writeln(const JsonEncoder.withIndent('  ').convert(json));
        } catch (e) {
          buffer.writeln(utf8.decode(bodyBytes));
        }
      } else if (contentType.contains('text/')) {
        buffer.writeln(utf8.decode(bodyBytes));
      } else {
        buffer.writeln('<binary data of ${bodyBytes.length} bytes>');
      }
    }
    
    buffer.writeln('└───────────────────');
    debugPrint(buffer.toString());
  }
}

/// Singleton HTTP logger service that can be used throughout the app
class HttpLogger {
  static final HttpLogger _instance = HttpLogger._internal();
  bool _enabled = true;
  
  factory HttpLogger() {
    return _instance;
  }
  
  HttpLogger._internal();
  
  /// Get a logging HTTP client
  http.Client getHttpClient() {
    return LoggingHttpClient(
      shouldLog: () => _enabled,
    );
  }
  
  /// Enable or disable HTTP logging
  void setEnabled(bool enabled) {
    _enabled = enabled;
  }
  
  /// Is HTTP logging currently enabled
  bool get isEnabled => _enabled;
}
