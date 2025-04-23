import 'package:flutter/foundation.dart';
import '../services/receipt_service.dart';

class InsightsProvider with ChangeNotifier {
  final ReceiptService _receiptService = ReceiptService();
  
  Map<String, double> _spendingByCategory = {};
  List<Map<String, dynamic>> _monthlyTrends = [];
  bool _isLoading = false;
  String? _error;
  String _selectedTimeRange = 'monthly'; // 'weekly' or 'monthly'
  
  // Getters
  Map<String, double> get spendingByCategory => _spendingByCategory;
  List<Map<String, dynamic>> get monthlyTrends => _monthlyTrends;
  bool get isLoading => _isLoading;
  String? get error => _error;
  String get selectedTimeRange => _selectedTimeRange;
  
  // Set time range
  void setTimeRange(String timeRange) {
    if (_selectedTimeRange != timeRange) {
      _selectedTimeRange = timeRange;
      notifyListeners();
      loadInsightsData(); // Reload data with new time range
    }
  }
  
  // Load insights data
  Future<void> loadInsightsData() async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    
    try {
      // In a real app, we would pass the time range to the API
      final results = await Future.wait([
        _receiptService.getSpendingByCategory(),
        _receiptService.getMonthlyTrends(),
      ]);
      
      _spendingByCategory = results[0] as Map<String, double>;
      _monthlyTrends = results[1] as List<Map<String, dynamic>>;
      
      // Filter data based on time range (in a real app, this would be done server-side)
      if (_selectedTimeRange == 'weekly') {
        // For this mock, just take the most recent month and adjust values
        _monthlyTrends = _monthlyTrends.take(1).map((month) {
          return {
            'month': 'This Week',
            'amount': (month['amount'] as double) / 4, // Rough approximation for weekly
          };
        }).toList();
        
        // Adjust category values for weekly view
        _spendingByCategory = Map.fromEntries(
          _spendingByCategory.entries.map(
            (entry) => MapEntry(entry.key, entry.value / 4)
          )
        );
      }
    } catch (e) {
      _error = 'Failed to load insights data: ${e.toString()}';
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
  
  // Get top merchants (mock implementation)
  List<Map<String, dynamic>> getTopMerchants() {
    return [
      {'name': 'SuperMart', 'total': 750000.0},
      {'name': 'ElectroStore', 'total': 650000.0},
      {'name': 'Coffee Spot', 'total': 350000.0},
      {'name': 'BookStore', 'total': 250000.0},
    ];
  }
  
  // Reset any errors
  void resetError() {
    _error = null;
    notifyListeners();
  }
}
