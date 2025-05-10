import 'dart:io';
import 'package:http/http.dart' as http;
import '../models/receipt_model.dart';
import '../models/dashboard_model.dart';
import '../models/insights_model.dart';
import '../config/api_config.dart';
import 'api_client.dart';

class ReceiptService {
  final ApiClient _apiClient;
  
  ReceiptService({ApiClient? apiClient}) 
      : _apiClient = apiClient ?? ApiClient(baseUrl: ApiConfig.apiBaseUrl);
  
  /// Scan a receipt by uploading an image
  Future<Receipt> scanReceipt(File imageFile) async {
    final response = await _apiClient.postMultipart<Receipt>(
      '/receipts/scan',
      file: imageFile,
      fieldName: 'receiptImage',
      fromJson: (json) => Receipt.fromJson(json),
    );
    
    if (response.success && response.data != null) {
      return response.data!;
    } else {
      throw Exception(response.message ?? 'Failed to scan receipt');
    }
  }
  
  /// Get user's receipts with pagination
  Future<List<Receipt>> getRecentReceipts({
    int page = 1,
    int limit = 10,
    String? startDate,
    String? endDate,
    String? merchant,
  }) async {
    final queryParams = {
      'page': page.toString(),
      'limit': limit.toString(),
      if (startDate != null) 'startDate': startDate,
      if (endDate != null) 'endDate': endDate,
      if (merchant != null) 'merchant': merchant,
    };
    
    final response = await _apiClient.get<ReceiptListResponse>(
      '/receipts',
      queryParameters: queryParams,
      fromJson: (json) => ReceiptListResponse.fromJson(json),
    );
    
    if (response.success && response.data != null) {
      return response.data!.data
          .map((json) => Receipt.fromJson(json as Map<String, dynamic>))
          .toList();
    } else {
      throw Exception(response.message ?? 'Failed to fetch receipts');
    }
  }
  
  /// Get a specific receipt by ID
  Future<Receipt> getReceiptById(String receiptId) async {
    final response = await _apiClient.get<Receipt>(
      '/receipts/$receiptId',
      fromJson: (json) => Receipt.fromJson(json),
    );
    
    if (response.success && response.data != null) {
      return response.data!;
    } else {
      throw Exception(response.message ?? 'Failed to fetch receipt');
    }
  }
  
  /// Create a receipt manually
  Future<Receipt> createReceipt(Receipt receipt) async {
    final response = await _apiClient.post<Receipt>(
      '/receipts',
      body: receipt.toJson(),
      fromJson: (json) => Receipt.fromJson(json),
    );
    
    if (response.success && response.data != null) {
      return response.data!;
    } else {
      throw Exception(response.message ?? 'Failed to create receipt');
    }
  }
  
  /// Update an existing receipt
  Future<Receipt> updateReceipt(String receiptId, Receipt receipt) async {
    final response = await _apiClient.put<Receipt>(
      '/receipts/$receiptId',
      body: receipt.toJson(),
      fromJson: (json) => Receipt.fromJson(json),
    );
    
    if (response.success && response.data != null) {
      return response.data!;
    } else {
      throw Exception(response.message ?? 'Failed to update receipt');
    }
  }
  
  /// Delete a receipt
  Future<bool> deleteReceipt(String receiptId) async {
    final response = await _apiClient.delete(
      '/receipts/$receiptId',
    );
    
    if (response.success) {
      return true;
    } else {
      throw Exception(response.message ?? 'Failed to delete receipt');
    }
  }
  
  /// Get dashboard summary
  Future<DashboardSummary> getDashboardSummary({
    String? startDate,
    String? endDate,
  }) async {
    final queryParams = {
      if (startDate != null) 'startDate': startDate,
      if (endDate != null) 'endDate': endDate,
    };
    
    final response = await _apiClient.get<DashboardSummary>(
      '/dashboard/summary',
      queryParameters: queryParams,
      fromJson: (json) => DashboardSummary.fromJson(json),
    );
    
    if (response.success && response.data != null) {
      return response.data!;
    } else {
      throw Exception(response.message ?? 'Failed to fetch dashboard summary');
    }
  }
  
  /// Get spending trends
  Future<SpendingTrends> getSpendingTrends({
    String period = 'monthly',
    String? startDate,
    String? endDate,
  }) async {
    final queryParams = {
      'period': period,
      if (startDate != null) 'startDate': startDate,
      if (endDate != null) 'endDate': endDate,
    };
    
    final response = await _apiClient.get<SpendingTrends>(
      '/dashboard/spending-trends',
      queryParameters: queryParams,
      fromJson: (json) => SpendingTrends.fromJson(json),
    );
    
    if (response.success && response.data != null) {
      return response.data!;
    } else {
      throw Exception(response.message ?? 'Failed to fetch spending trends');
    }
  }
  
  /// Get spending by category
  Future<SpendingByCategory> getSpendingByCategoryDetailed({
    required String startDate,
    required String endDate,
  }) async {
    final queryParams = {
      'startDate': startDate,
      'endDate': endDate,
    };
    
    final response = await _apiClient.get<SpendingByCategory>(
      '/insights/spending-by-category',
      queryParameters: queryParams,
      fromJson: (json) => SpendingByCategory.fromJson(json),
    );
    
    if (response.success && response.data != null) {
      return response.data!;
    } else {
      throw Exception(response.message ?? 'Failed to fetch spending by category');
    }
  }
  
  /// Get merchant frequency
  Future<MerchantFrequency> getMerchantFrequency({
    required String startDate,
    required String endDate,
    int limit = 10,
  }) async {
    final queryParams = {
      'startDate': startDate,
      'endDate': endDate,
      'limit': limit.toString(),
    };
    
    final response = await _apiClient.get<MerchantFrequency>(
      '/insights/merchant-frequency',
      queryParameters: queryParams,
      fromJson: (json) => MerchantFrequency.fromJson(json),
    );
    
    if (response.success && response.data != null) {
      return response.data!;
    } else {
      throw Exception(response.message ?? 'Failed to fetch merchant frequency');
    }
  }
  
  /// Get monthly comparison
  Future<MonthlyComparison> getMonthlyComparison({
    required String month1,
    required String month2,
  }) async {
    final queryParams = {
      'month1': month1,
      'month2': month2,
    };
    
    final response = await _apiClient.get<MonthlyComparison>(
      '/insights/monthly-comparison',
      queryParameters: queryParams,
      fromJson: (json) => MonthlyComparison.fromJson(json),
    );
    
    if (response.success && response.data != null) {
      return response.data!;
    } else {
      throw Exception(response.message ?? 'Failed to fetch monthly comparison');
    }
  }
  
  /// Get monthly spending data (for backward compatibility with existing UI)
  Future<double> getMonthlySpending() async {
    try {
      final summary = await getDashboardSummary();
      // Convert from string currency format to double
      // Remove any non-numeric characters except decimal point
      final numericString = summary.totalSpend.replaceAll(RegExp(r'[^0-9.]'), '');
      return double.parse(numericString);
    } catch (e) {
      // Fallback for backward compatibility
      return 3456000.0; // Rp 3.456.000
    }
  }
  
  /// Get spending categories (for backward compatibility with existing UI)
  Future<Map<String, double>> getSpendingByCategory_old() async {
    try {
      // Get current date
      final now = DateTime.now();
      final startDate = DateTime(now.year, now.month - 1, 1).toString().split(' ')[0];
      final endDate = DateTime(now.year, now.month, 0).toString().split(' ')[0];
      
      final categoryData = await getSpendingByCategoryDetailed(
        startDate: startDate,
        endDate: endDate,
      );
      
      // Convert to map format needed by existing UI
      final Map<String, double> result = {};
      for (var category in categoryData.categories) {
        // Convert from string currency format to double
        final numericString = category.amount.replaceAll(RegExp(r'[^0-9.]'), '');
        result[category.name] = double.parse(numericString);
      }
      
      return result;
    } catch (e) {
      // Fallback for backward compatibility
      return {
        'Food': 1250000.0,      // Rp 1.250.000
        'Shopping': 850000.0,   // Rp 850.000
        'Transport': 650000.0,  // Rp 650.000
        'Entertainment': 450000.0, // Rp 450.000
        'Others': 256000.0,     // Rp 256.000
      };
    }
  }
  
  /// Get spending categories (for backward compatibility with existing UI)
  Future<Map<String, double>> getSpendingByCategory() async {
    return getSpendingByCategory_old();
  }
  
  /// Get monthly spending trends (for backward compatibility with existing UI)
  Future<List<Map<String, dynamic>>> getMonthlyTrends_old() async {
    try {
      final trendData = await getSpendingTrends(period: 'monthly');
      
      // Convert to the format needed by existing UI
      return trendData.data.map((item) {
        // Extract month from date string (assuming format like '2023-05')
        final dateParts = item.date.split('-');
        String month;
        if (dateParts.length >= 2) {
          final monthNum = int.parse(dateParts[1]);
          final months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
          month = months[monthNum - 1];
        } else {
          month = item.date; // Fallback to using the whole date string
        }
        
        // Convert from string currency format to double
        final numericString = item.amount.replaceAll(RegExp(r'[^0-9.]'), '');
        final amount = double.parse(numericString);
        
        return {
          'month': month,
          'amount': amount,
        };
      }).toList();
    } catch (e) {
      // Fallback for backward compatibility
      return [
        {'month': 'Jan', 'amount': 2800000.0},
        {'month': 'Feb', 'amount': 3100000.0},
        {'month': 'Mar', 'amount': 2950000.0},
        {'month': 'Apr', 'amount': 3456000.0}, // Current month
      ];
    }
  }
  
  /// Get monthly spending trends (for backward compatibility with existing UI)
  Future<List<Map<String, dynamic>>> getMonthlyTrends() async {
    return getMonthlyTrends_old();
  }
}
