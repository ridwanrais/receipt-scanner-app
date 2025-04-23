import 'package:flutter/foundation.dart';

class ProfileProvider with ChangeNotifier {
  String _name = 'John Doe';
  String _email = 'john.doe@example.com';
  String _avatar = 'https://i.pravatar.cc/150?img=8';
  bool _isDarkMode = false;
  bool _isLoading = false;
  String? _error;
  
  // Getters
  String get name => _name;
  String get email => _email;
  String get avatar => _avatar;
  bool get isDarkMode => _isDarkMode;
  bool get isLoading => _isLoading;
  String? get error => _error;
  
  // Toggle dark mode
  void toggleDarkMode() {
    _isDarkMode = !_isDarkMode;
    notifyListeners();
  }
  
  // Update user profile (mock implementation)
  Future<void> updateProfile({String? name, String? email}) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    
    try {
      // Simulate network delay
      await Future.delayed(const Duration(seconds: 1));
      
      // Update profile data
      if (name != null) _name = name;
      if (email != null) _email = email;
    } catch (e) {
      _error = 'Failed to update profile: ${e.toString()}';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
  
  // Reset any errors
  void resetError() {
    _error = null;
    notifyListeners();
  }
  
  // Log out (mock implementation)
  Future<void> logout() async {
    _isLoading = true;
    notifyListeners();
    
    try {
      // Simulate network delay
      await Future.delayed(const Duration(milliseconds: 800));
      
      // In a real app, we would clear tokens, session info, etc.
    } catch (e) {
      _error = 'Failed to logout: ${e.toString()}';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
