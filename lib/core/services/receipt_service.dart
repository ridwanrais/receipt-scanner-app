import 'dart:io';
import 'package:http/http.dart' as http;
import '../models/receipt_model.dart';

class ReceiptService {
  /// Mock function to simulate processing a receipt image
  /// In a real app, this would make an API call to a backend service
  Future<Receipt> scanReceipt(File imageFile) async {
    // Simulate network delay
    await Future.delayed(const Duration(seconds: 2));
    
    // Mock response data
    final Map<String, dynamic> mockResponse = {
      "merchant": "Coffee Spot",
      "date": "2025-04-20",
      "total": "Rp 58.000",
      "tax": "Rp 5.000",
      "subtotal": "Rp 53.000",
      "items": [
        {"name": "Latte", "qty": 1, "price": "Rp 25.000"},
        {"name": "Croissant", "qty": 1, "price": "Rp 28.000"}
      ]
    };
    
    return Receipt.fromJson(mockResponse);
  }
  
  /// Get user's receipts (mock data)
  Future<List<Receipt>> getRecentReceipts() async {
    await Future.delayed(const Duration(milliseconds: 800));
    
    final List<Map<String, dynamic>> mockReceipts = [
      {
        "merchant": "Coffee Spot",
        "date": "2025-04-20",
        "total": "Rp 58.000",
        "tax": "Rp 5.000",
        "subtotal": "Rp 53.000",
        "items": [
          {"name": "Latte", "qty": 1, "price": "Rp 25.000"},
          {"name": "Croissant", "qty": 1, "price": "Rp 28.000"}
        ]
      },
      {
        "merchant": "SuperMart",
        "date": "2025-04-18",
        "total": "Rp 145.500",
        "tax": "Rp 13.000",
        "subtotal": "Rp 132.500",
        "items": [
          {"name": "Rice 5kg", "qty": 1, "price": "Rp 75.000"},
          {"name": "Eggs (12)", "qty": 1, "price": "Rp 32.500"},
          {"name": "Cooking Oil", "qty": 1, "price": "Rp 25.000"}
        ]
      },
      {
        "merchant": "BookStore",
        "date": "2025-04-15",
        "total": "Rp 124.000",
        "tax": "Rp 0",
        "subtotal": "Rp 124.000",
        "items": [
          {"name": "Flutter Book", "qty": 1, "price": "Rp 124.000"}
        ]
      },
      {
        "merchant": "ElectroStore",
        "date": "2025-04-10",
        "total": "Rp 3.250.000",
        "tax": "Rp 295.000",
        "subtotal": "Rp 2.955.000",
        "items": [
          {"name": "Headphones", "qty": 1, "price": "Rp 1.500.000"},
          {"name": "Phone Case", "qty": 1, "price": "Rp 255.000"},
          {"name": "USB Cable", "qty": 2, "price": "Rp 600.000"}
        ]
      }
    ];
    
    return mockReceipts.map((json) => Receipt.fromJson(json)).toList();
  }
  
  /// Get monthly spending data (mock)
  Future<double> getMonthlySpending() async {
    await Future.delayed(const Duration(milliseconds: 500));
    return 3456000.0; // Rp 3.456.000
  }
  
  /// Get spending categories (mock)
  Future<Map<String, double>> getSpendingByCategory() async {
    await Future.delayed(const Duration(milliseconds: 700));
    
    return {
      'Food': 1250000.0,      // Rp 1.250.000
      'Shopping': 850000.0,   // Rp 850.000
      'Transport': 650000.0,  // Rp 650.000
      'Entertainment': 450000.0, // Rp 450.000
      'Others': 256000.0,     // Rp 256.000
    };
  }
  
  /// Get monthly spending trends (mock)
  Future<List<Map<String, dynamic>>> getMonthlyTrends() async {
    await Future.delayed(const Duration(milliseconds: 600));
    
    return [
      {'month': 'Jan', 'amount': 2800000.0},
      {'month': 'Feb', 'amount': 3100000.0},
      {'month': 'Mar', 'amount': 2950000.0},
      {'month': 'Apr', 'amount': 3456000.0}, // Current month
    ];
  }
}
