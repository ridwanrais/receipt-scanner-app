import 'package:flutter/foundation.dart';
import '../services/receipt_service.dart';
import '../models/receipt_model.dart';

class DashboardProvider with ChangeNotifier {
  final ReceiptService _receiptService = ReceiptService();
  
  double _totalMonthlySpending = 0;
  Map<String, double> _spendingByCategory = {};
  List<Map<String, dynamic>> _monthlyTrends = [];
  List<Receipt> _recentReceipts = [];
  bool _isLoading = false;
  String? _error;
  
  // Getters
  double get totalMonthlySpending => _totalMonthlySpending;
  Map<String, double> get spendingByCategory => _spendingByCategory;
  List<Map<String, dynamic>> get monthlyTrends => _monthlyTrends;
  List<Receipt> get recentReceipts => _recentReceipts;
  bool get isLoading => _isLoading;
  String? get error => _error;
  
  // Load all dashboard data
  Future<void> loadDashboardData() async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    
    try {
      // Load data in parallel
      final results = await Future.wait([
        _receiptService.getMonthlySpending(),
        _receiptService.getSpendingByCategory(),
        _receiptService.getMonthlyTrends(),
        _receiptService.getRecentReceipts(),
      ]);
      
      _totalMonthlySpending = results[0] as double;
      _spendingByCategory = results[1] as Map<String, double>;
      _monthlyTrends = results[2] as List<Map<String, dynamic>>;
      _recentReceipts = (results[3] as List<Receipt>).take(5).toList(); // Only show 5 most recent
    } catch (e) {
      _error = 'Failed to load dashboard data: ${e.toString()}';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
  
  // Format currency (simple implementation)
  String formatCurrency(double amount) {
    return 'Rp ${amount.toStringAsFixed(0).replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]}.'
    )}';
  }
  
  // Reset any errors
  void resetError() {
    _error = null;
    notifyListeners();
  }
}
