import 'dart:io';
import 'package:flutter/foundation.dart';
import '../models/receipt_model.dart';
import '../services/receipt_service.dart';

class ReceiptProvider with ChangeNotifier {
  final ReceiptService _receiptService = ReceiptService();
  
  List<Receipt> _receipts = [];
  Receipt? _currentReceipt;
  bool _isLoading = false;
  String? _error;
  
  // Getters
  List<Receipt> get receipts => _receipts;
  Receipt? get currentReceipt => _currentReceipt;
  bool get isLoading => _isLoading;
  String? get error => _error;
  
  // Fetch all receipts
  Future<void> fetchReceipts() async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    
    try {
      _receipts = await _receiptService.getRecentReceipts();
    } catch (e) {
      _error = 'Failed to load receipts: ${e.toString()}';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
  
  // Scan a new receipt
  Future<void> scanReceipt(File imageFile) async {
    _isLoading = true;
    _error = null;
    _currentReceipt = null;
    notifyListeners();
    
    try {
      _currentReceipt = await _receiptService.scanReceipt(imageFile);
    } catch (e) {
      _error = 'Failed to scan receipt: ${e.toString()}';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
  
  // Save the current receipt
  void saveCurrentReceipt() {
    if (_currentReceipt != null) {
      _receipts = [_currentReceipt!, ..._receipts];
      _currentReceipt = null;
      notifyListeners();
    }
  }
  
  // Reset current receipt
  void resetCurrentReceipt() {
    _currentReceipt = null;
    notifyListeners();
  }
  
  // Reset any errors
  void resetError() {
    _error = null;
    notifyListeners();
  }
}
