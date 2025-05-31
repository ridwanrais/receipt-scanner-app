import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:alice/alice.dart';
import 'package:flutter/foundation.dart';

import '../services/api_inspector.dart';
import '../config/app_config.dart';

class Logger {
  static final Logger _instance = Logger._internal();
  factory Logger() => _instance;
  Logger._internal();

  late File _logFile;
  bool _initialized = false;
  String _logFileName = '';
  Alice? _alice;
  bool _aliceAvailable = false;

  Future<void> initialize() async {
    if (_initialized) return;
    
    final directory = await getApplicationDocumentsDirectory();
    final logDir = Directory('${directory.path}/app_logs');
    
    if (!await logDir.exists()) {
      await logDir.create();
    }
    
    final timestamp = DateTime.now().toIso8601String();
    _logFileName = 'app_log_$timestamp.txt';
    _logFile = File('${logDir.path}/$_logFileName');
    
    await _logFile.create();
    _initialized = true;
    
    // Only try to get Alice if debug tools are enabled
    if (AppConfig.enableDebugTools) {
      try {
        _alice = ApiInspector().getAlice();
        _aliceAvailable = true;
      } catch (e) {
        print('Logger: Alice not available: $e');
        _aliceAvailable = false;
      }
    }
    
    // Log initialization
    print('Logger initialized');
  }

  String getLogFileName() => _logFileName;

  void log(String message, {String level = 'INFO'}) {
    if (!_initialized) {
      print('Logger not initialized! Message: $message');
      return;
    }
    
    final timestamp = DateTime.now().toIso8601String();
    final logMessage = '[$timestamp] [$level] $message\n';
    
    // Write to file
    _logFile.writeAsStringSync(logMessage, mode: FileMode.append);
    
    // Also print to console for debugging
    print(logMessage.trim());
    
    // Log to Alice if available
    if (_aliceAvailable && _alice != null) {
      try {
        final aliceLevel = level == 'ERROR' 
            ? DiagnosticLevel.error
            : level == 'DEBUG'
                ? DiagnosticLevel.debug
                : DiagnosticLevel.info;
        
        _alice!.addLog(AliceLog(
          level: aliceLevel,
          timestamp: DateTime.now(),
          message: logMessage,
        ));
      } catch (e) {
        print('Logger: Failed to log to Alice: $e');
      }
    }
  }

  void error(String message, {StackTrace? stackTrace}) {
    final errorLog = stackTrace != null
        ? '[$message]\n$stackTrace'
        : message;
    log(errorLog, level: 'ERROR');
    
    // Additional Alice logging if available
    if (_aliceAvailable && _alice != null) {
      try {
        _alice!.addLog(AliceLog(
          level: DiagnosticLevel.error,
          timestamp: DateTime.now(),
          message: errorLog,
          error: Error.safeToString(errorLog),
          stackTrace: stackTrace,
        ));
      } catch (e) {
        print('Logger: Failed to log error to Alice: $e');
      }
    }
  }

  void info(String message) {
    log(message, level: 'INFO');
  }

  void debug(String message) {
    log(message, level: 'DEBUG');
  }

  void warning(String message) {
    log(message, level: 'WARNING');
  }
}
