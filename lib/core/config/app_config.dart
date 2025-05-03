import 'package:flutter/foundation.dart';

/// Centralized configuration class for application-wide settings
class AppConfig {
  /// Whether debugging tools like API inspector should be enabled
  /// 
  /// This should be true for development and staging builds, false for production
  static bool get enableDebugTools {
    // Automatically disable in release mode, enable in debug & profile modes
    return kDebugMode || kProfileMode;
    
    // Alternatively, you can use a constant to override this:
    // final bool forceEnableToolsInRelease = false;
    // return kDebugMode || kProfileMode || (kReleaseMode && forceEnableToolsInRelease);
  }
  
  /// Whether the app is running in development environment
  static bool get isDev => kDebugMode;
  
  /// Whether the app is running in test/staging environment
  static bool get isStaging => kProfileMode;
  
  /// Whether the app is running in production environment
  static bool get isProd => kReleaseMode;
}
