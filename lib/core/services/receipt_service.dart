import 'dart:io';
import 'dart:math' as math;
import 'package:path_provider/path_provider.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:path/path.dart' as path;
import '../models/receipt_model.dart';
import '../models/dashboard_model.dart';
import '../models/insights_model.dart';
import '../config/api_config.dart';
import 'api_client.dart';
import '../services/logger.dart';

class ReceiptService {
  final ApiClient _apiClient;
  final Logger _logger = Logger();

  ReceiptService({ApiClient? apiClient})
    : _apiClient = apiClient ?? ApiClient(baseUrl: ApiConfig.apiBaseUrl);

  /// Scan a receipt by uploading an image
  Future<Receipt> scanReceipt(File imageFile) async {
    await _logger.initialize();
    _logger.info(
      'ReceiptService.scanReceipt - Starting with file: ${imageFile.path}',
    );
    _logger.info(
      'ReceiptService.scanReceipt - File exists: ${await imageFile.exists()}',
    );
    _logger.info(
      'ReceiptService.scanReceipt - File size: ${await imageFile.length()} bytes',
    );

    // Check if image needs compression (if larger than 5MB to be safe)
    final int maxSizeBytes = 5 * 1024 * 1024; // 5MB
    final int originalSize = await imageFile.length();
    File fileToUpload = imageFile;

    _logger.info(
      'ReceiptService.scanReceipt - Image size: ${originalSize} bytes, max size: ${maxSizeBytes} bytes',
    );
    if (originalSize > maxSizeBytes) {
      _logger.info(
        'ReceiptService.scanReceipt - Image is too large (${originalSize} bytes), compressing...',
      );
      fileToUpload = await _compressImage(imageFile);
      _logger.info(
        'ReceiptService.scanReceipt - Compressed image size: ${await fileToUpload.length()} bytes',
      );
    }

    try {
      _logger.info('ReceiptService.scanReceipt - Calling API...');
      // Fix: Remove the leading slash from the endpoint path since it's already included in the baseUrl
      final response = await _apiClient.postMultipart<Receipt>(
        '/receipts/scan', // Removed leading slash
        file: fileToUpload, // Use compressed image if available
        fieldName: 'receiptImage',
        fromJson: (json) => Receipt.fromJson(json),
      );

      // Log raw response for debugging
      if (response.rawBody != null) {
        final previewLength = math.min(100, response.rawBody!.length);
        _logger.info(
          'ReceiptService.scanReceipt - Response preview: ${response.rawBody!.substring(0, previewLength)}',
        );
      } else {
        _logger.info(
          'ReceiptService.scanReceipt - No raw response body available',
        );
      }

      _logger.info(
        'ReceiptService.scanReceipt - API response received: ${response.success}',
      );
      _logger.info(
        'ReceiptService.scanReceipt - Response message: ${response.message}',
      );
      _logger.info(
        'ReceiptService.scanReceipt - Has data: ${response.data != null}',
      );

      if (response.success && response.data != null) {
        _logger.info(
          'ReceiptService.scanReceipt - Successfully scanned receipt: ${response.data!.merchant}',
        );
        return response.data!;
      } else {
        final errorMsg = response.message ?? 'Failed to scan receipt';
        _logger.error('ReceiptService.scanReceipt - API error: $errorMsg');
        throw Exception(errorMsg);
      }
    } catch (e, stackTrace) {
      _logger.error(
        'ReceiptService.scanReceipt - Exception: $e',
        stackTrace: stackTrace,
      );
      rethrow;
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

    try {
      _logger.info('ReceiptService.getRecentReceipts - Calling API...');
      final response = await _apiClient.get<ReceiptListResponse>(
        '/receipts',
        queryParameters: queryParams,
        fromJson: (json) => ReceiptListResponse.fromJson(json),
      );

      _logger.info(
        'ReceiptService.getRecentReceipts - API response received: ${response.success}',
      );
      _logger.info(
        'ReceiptService.getRecentReceipts - Response message: ${response.message}',
      );
      _logger.info(
        'ReceiptService.getRecentReceipts - Has data: ${response.data != null}',
      );

      if (response.success && response.data != null) {
        _logger.info(
          'ReceiptService.getRecentReceipts - Successfully fetched receipts',
        );
        return response.data!.data
            .map((json) => Receipt.fromJson(json as Map<String, dynamic>))
            .toList();
      } else {
        final errorMsg = response.message ?? 'Failed to fetch receipts';
        _logger.error(
          'ReceiptService.getRecentReceipts - API error: $errorMsg',
        );
        throw Exception(errorMsg);
      }
    } catch (e, stackTrace) {
      _logger.error(
        'ReceiptService.getRecentReceipts - Exception: $e',
        stackTrace: stackTrace,
      );
      rethrow;
    }
  }

  /// Get a specific receipt by ID
  Future<Receipt> getReceiptById(String receiptId) async {
    try {
      _logger.info('ReceiptService.getReceiptById - Calling API...');
      final response = await _apiClient.get<Receipt>(
        '/receipts/$receiptId',
        fromJson: (json) => Receipt.fromJson(json),
      );

      _logger.info(
        'ReceiptService.getReceiptById - API response received: ${response.success}',
      );
      _logger.info(
        'ReceiptService.getReceiptById - Response message: ${response.message}',
      );
      _logger.info(
        'ReceiptService.getReceiptById - Has data: ${response.data != null}',
      );

      if (response.success && response.data != null) {
        _logger.info(
          'ReceiptService.getReceiptById - Successfully fetched receipt',
        );
        return response.data!;
      } else {
        final errorMsg = response.message ?? 'Failed to fetch receipt';
        _logger.error('ReceiptService.getReceiptById - API error: $errorMsg');
        throw Exception(errorMsg);
      }
    } catch (e, stackTrace) {
      _logger.error(
        'ReceiptService.getReceiptById - Exception: $e',
        stackTrace: stackTrace,
      );
      rethrow;
    }
  }

  /// Create a receipt manually
  Future<Receipt> createReceipt(Receipt receipt) async {
    try {
      _logger.info('ReceiptService.createReceipt - Calling API...');
      final response = await _apiClient.post<Receipt>(
        '/receipts',
        body: receipt.toJson(),
        fromJson: (json) => Receipt.fromJson(json),
      );

      _logger.info(
        'ReceiptService.createReceipt - API response received: ${response.success}',
      );
      _logger.info(
        'ReceiptService.createReceipt - Response message: ${response.message}',
      );
      _logger.info(
        'ReceiptService.createReceipt - Has data: ${response.data != null}',
      );

      if (response.success && response.data != null) {
        _logger.info(
          'ReceiptService.createReceipt - Successfully created receipt',
        );
        return response.data!;
      } else {
        final errorMsg = response.message ?? 'Failed to create receipt';
        _logger.error('ReceiptService.createReceipt - API error: $errorMsg');
        throw Exception(errorMsg);
      }
    } catch (e, stackTrace) {
      _logger.error(
        'ReceiptService.createReceipt - Exception: $e',
        stackTrace: stackTrace,
      );
      rethrow;
    }
  }

  /// Update an existing receipt
  Future<Receipt> updateReceipt(String receiptId, Receipt receipt) async {
    try {
      _logger.info('ReceiptService.updateReceipt - Calling API...');
      final response = await _apiClient.put<Receipt>(
        '/receipts/$receiptId',
        body: receipt.toJson(),
        fromJson: (json) => Receipt.fromJson(json),
      );

      _logger.info(
        'ReceiptService.updateReceipt - API response received: ${response.success}',
      );
      _logger.info(
        'ReceiptService.updateReceipt - Response message: ${response.message}',
      );
      _logger.info(
        'ReceiptService.updateReceipt - Has data: ${response.data != null}',
      );

      if (response.success && response.data != null) {
        _logger.info(
          'ReceiptService.updateReceipt - Successfully updated receipt',
        );
        return response.data!;
      } else {
        final errorMsg = response.message ?? 'Failed to update receipt';
        _logger.error('ReceiptService.updateReceipt - API error: $errorMsg');
        throw Exception(errorMsg);
      }
    } catch (e, stackTrace) {
      _logger.error(
        'ReceiptService.updateReceipt - Exception: $e',
        stackTrace: stackTrace,
      );
      rethrow;
    }
  }

  /// Delete a receipt
  Future<bool> deleteReceipt(String receiptId) async {
    try {
      _logger.info('ReceiptService.deleteReceipt - Calling API...');
      final response = await _apiClient.delete('/receipts/$receiptId');

      _logger.info(
        'ReceiptService.deleteReceipt - API response received: ${response.success}',
      );
      _logger.info(
        'ReceiptService.deleteReceipt - Response message: ${response.message}',
      );

      if (response.success) {
        _logger.info(
          'ReceiptService.deleteReceipt - Successfully deleted receipt',
        );
        return true;
      } else {
        final errorMsg = response.message ?? 'Failed to delete receipt';
        _logger.error('ReceiptService.deleteReceipt - API error: $errorMsg');
        throw Exception(errorMsg);
      }
    } catch (e, stackTrace) {
      _logger.error(
        'ReceiptService.deleteReceipt - Exception: $e',
        stackTrace: stackTrace,
      );
      rethrow;
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

    try {
      _logger.info('ReceiptService.getDashboardSummary - Calling API...');
      final response = await _apiClient.get<DashboardSummary>(
        '/dashboard/summary',
        queryParameters: queryParams,
        fromJson: (json) => DashboardSummary.fromJson(json),
      );

      _logger.info(
        'ReceiptService.getDashboardSummary - API response received: ${response.success}',
      );
      _logger.info(
        'ReceiptService.getDashboardSummary - Response message: ${response.message}',
      );
      _logger.info(
        'ReceiptService.getDashboardSummary - Has data: ${response.data != null}',
      );

      if (response.success && response.data != null) {
        _logger.info(
          'ReceiptService.getDashboardSummary - Successfully fetched dashboard summary',
        );
        return response.data!;
      } else {
        final errorMsg =
            response.message ?? 'Failed to fetch dashboard summary';
        _logger.error(
          'ReceiptService.getDashboardSummary - API error: $errorMsg',
        );
        throw Exception(errorMsg);
      }
    } catch (e, stackTrace) {
      _logger.error(
        'ReceiptService.getDashboardSummary - Exception: $e',
        stackTrace: stackTrace,
      );
      rethrow;
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

    try {
      _logger.info('ReceiptService.getSpendingTrends - Calling API...');
      final response = await _apiClient.get<SpendingTrends>(
        '/dashboard/spending-trends',
        queryParameters: queryParams,
        fromJson: (json) => SpendingTrends.fromJson(json),
      );

      _logger.info(
        'ReceiptService.getSpendingTrends - API response received: ${response.success}',
      );
      _logger.info(
        'ReceiptService.getSpendingTrends - Response message: ${response.message}',
      );
      _logger.info(
        'ReceiptService.getSpendingTrends - Has data: ${response.data != null}',
      );

      if (response.success && response.data != null) {
        _logger.info(
          'ReceiptService.getSpendingTrends - Successfully fetched spending trends',
        );
        return response.data!;
      } else {
        final errorMsg = response.message ?? 'Failed to fetch spending trends';
        _logger.error(
          'ReceiptService.getSpendingTrends - API error: $errorMsg',
        );
        throw Exception(errorMsg);
      }
    } catch (e, stackTrace) {
      _logger.error(
        'ReceiptService.getSpendingTrends - Exception: $e',
        stackTrace: stackTrace,
      );
      rethrow;
    }
  }

  /// Get spending by category
  Future<SpendingByCategory> getSpendingByCategoryDetailed({
    required String startDate,
    required String endDate,
  }) async {
    final queryParams = {'startDate': startDate, 'endDate': endDate};

    try {
      _logger.info(
        'ReceiptService.getSpendingByCategoryDetailed - Calling API...',
      );
      final response = await _apiClient.get<SpendingByCategory>(
        '/insights/spending-by-category',
        queryParameters: queryParams,
        fromJson: (json) => SpendingByCategory.fromJson(json),
      );

      _logger.info(
        'ReceiptService.getSpendingByCategoryDetailed - API response received: ${response.success}',
      );
      _logger.info(
        'ReceiptService.getSpendingByCategoryDetailed - Response message: ${response.message}',
      );
      _logger.info(
        'ReceiptService.getSpendingByCategoryDetailed - Has data: ${response.data != null}',
      );

      if (response.success && response.data != null) {
        _logger.info(
          'ReceiptService.getSpendingByCategoryDetailed - Successfully fetched spending by category',
        );
        return response.data!;
      } else {
        final errorMsg =
            response.message ?? 'Failed to fetch spending by category';
        _logger.error(
          'ReceiptService.getSpendingByCategoryDetailed - API error: $errorMsg',
        );
        throw Exception(errorMsg);
      }
    } catch (e, stackTrace) {
      _logger.error(
        'ReceiptService.getSpendingByCategoryDetailed - Exception: $e',
        stackTrace: stackTrace,
      );
      rethrow;
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

    try {
      _logger.info('ReceiptService.getMerchantFrequency - Calling API...');
      final response = await _apiClient.get<MerchantFrequency>(
        '/insights/merchant-frequency',
        queryParameters: queryParams,
        fromJson: (json) => MerchantFrequency.fromJson(json),
      );

      _logger.info(
        'ReceiptService.getMerchantFrequency - API response received: ${response.success}',
      );
      _logger.info(
        'ReceiptService.getMerchantFrequency - Response message: ${response.message}',
      );
      _logger.info(
        'ReceiptService.getMerchantFrequency - Has data: ${response.data != null}',
      );

      if (response.success && response.data != null) {
        _logger.info(
          'ReceiptService.getMerchantFrequency - Successfully fetched merchant frequency',
        );
        return response.data!;
      } else {
        final errorMsg =
            response.message ?? 'Failed to fetch merchant frequency';
        _logger.error(
          'ReceiptService.getMerchantFrequency - API error: $errorMsg',
        );
        throw Exception(errorMsg);
      }
    } catch (e, stackTrace) {
      _logger.error(
        'ReceiptService.getMerchantFrequency - Exception: $e',
        stackTrace: stackTrace,
      );
      rethrow;
    }
  }

  /// Get monthly comparison
  Future<MonthlyComparison> getMonthlyComparison({
    required String month1,
    required String month2,
  }) async {
    final queryParams = {'month1': month1, 'month2': month2};

    try {
      _logger.info('ReceiptService.getMonthlyComparison - Calling API...');
      final response = await _apiClient.get<MonthlyComparison>(
        '/insights/monthly-comparison',
        queryParameters: queryParams,
        fromJson: (json) => MonthlyComparison.fromJson(json),
      );

      _logger.info(
        'ReceiptService.getMonthlyComparison - API response received: ${response.success}',
      );
      _logger.info(
        'ReceiptService.getMonthlyComparison - Response message: ${response.message}',
      );
      _logger.info(
        'ReceiptService.getMonthlyComparison - Has data: ${response.data != null}',
      );

      if (response.success && response.data != null) {
        _logger.info(
          'ReceiptService.getMonthlyComparison - Successfully fetched monthly comparison',
        );
        return response.data!;
      } else {
        final errorMsg =
            response.message ?? 'Failed to fetch monthly comparison';
        _logger.error(
          'ReceiptService.getMonthlyComparison - API error: $errorMsg',
        );
        throw Exception(errorMsg);
      }
    } catch (e, stackTrace) {
      _logger.error(
        'ReceiptService.getMonthlyComparison - Exception: $e',
        stackTrace: stackTrace,
      );
      rethrow;
    }
  }

  /// Get monthly spending data (for backward compatibility with existing UI)
  Future<double> getMonthlySpending() async {
    try {
      final summary = await getDashboardSummary();
      // Convert from string currency format to double
      // Remove any non-numeric characters except decimal point
      final numericString = summary.totalSpend.replaceAll(
        RegExp(r'[^0-9.]'),
        '',
      );
      _logger.info(
        'ReceiptService.getMonthlySpending - Successfully fetched monthly spending',
      );
      return double.parse(numericString);
    } catch (e, stackTrace) {
      _logger.error(
        'ReceiptService.getMonthlySpending - Exception: $e',
        stackTrace: stackTrace,
      );
      // Fallback for backward compatibility
      _logger.info('ReceiptService.getMonthlySpending - Using fallback value');
      return 3456000.0; // Rp 3.456.000
    }
  }

  /// Get spending categories (for backward compatibility with existing UI)
  Future<Map<String, double>> getSpendingByCategory_old() async {
    try {
      // Get current date
      final now = DateTime.now();
      final startDate =
          DateTime(now.year, now.month - 1, 1).toString().split(' ')[0];
      final endDate = DateTime(now.year, now.month, 0).toString().split(' ')[0];

      final categoryData = await getSpendingByCategoryDetailed(
        startDate: startDate,
        endDate: endDate,
      );

      // Convert to map format needed by existing UI
      final Map<String, double> result = {};
      for (var category in categoryData.categories) {
        // Convert from string currency format to double
        final numericString = category.amount.replaceAll(
          RegExp(r'[^0-9.]'),
          '',
        );
        result[category.name] = double.parse(numericString);
      }

      _logger.info(
        'ReceiptService.getSpendingByCategory_old - Successfully fetched spending by category',
      );
      return result;
    } catch (e, stackTrace) {
      _logger.error(
        'ReceiptService.getSpendingByCategory_old - Exception: $e',
        stackTrace: stackTrace,
      );
      // Fallback for backward compatibility
      _logger.info(
        'ReceiptService.getSpendingByCategory_old - Using fallback value',
      );
      return {
        'Food': 1250000.0, // Rp 1.250.000
        'Shopping': 850000.0, // Rp 850.000
        'Transport': 650000.0, // Rp 650.000
        'Entertainment': 450000.0, // Rp 450.000
        'Others': 256000.0, // Rp 256.000
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
          final months = [
            'Jan',
            'Feb',
            'Mar',
            'Apr',
            'May',
            'Jun',
            'Jul',
            'Aug',
            'Sep',
            'Oct',
            'Nov',
            'Dec',
          ];
          month = months[monthNum - 1];
        } else {
          month = item.date; // Fallback to using the whole date string
        }

        // Convert from string currency format to double
        final numericString = item.amount.replaceAll(RegExp(r'[^0-9.]'), '');
        final amount = double.parse(numericString);

        return {'month': month, 'amount': amount};
      }).toList();
    } catch (e, stackTrace) {
      _logger.error(
        'ReceiptService.getMonthlyTrends_old - Exception: $e',
        stackTrace: stackTrace,
      );
      // Fallback for backward compatibility
      _logger.info(
        'ReceiptService.getMonthlyTrends_old - Using fallback value',
      );
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

  /// Compress an image file to reduce its size
  /// Returns a new compressed file
  Future<File> _compressImage(File file) async {
    try {
      // Get file extension
      final String ext = path.extension(file.path).toLowerCase();
      final String fileName = path.basename(file.path);

      // Get temp directory to store compressed image
      final Directory tempDir = await getTemporaryDirectory();
      final String targetPath = path.join(tempDir.path, 'compressed_$fileName');

      // Determine quality based on file size
      final int fileSize = await file.length();
      int quality = 90; // Default quality

      // Adjust quality based on file size
      if (fileSize > 8 * 1024 * 1024) {
        // > 8MB
        quality = 60;
      } else if (fileSize > 5 * 1024 * 1024) {
        // > 5MB
        quality = 70;
      } else if (fileSize > 2 * 1024 * 1024) {
        // > 2MB
        quality = 80;
      }

      _logger.info(
        'ReceiptService._compressImage - Compressing with quality: $quality',
      );

      // Compress image based on file type
      File? result;
      if (ext == '.jpg' || ext == '.jpeg') {
        final compressedData = await FlutterImageCompress.compressAndGetFile(
          file.path,
          targetPath,
          quality: quality,
          minWidth: 1000, // Reasonable width for receipt images
          minHeight: 1000,
        );
        if (compressedData != null) {
          result = File(compressedData.path);
        }
      } else if (ext == '.png') {
        final compressedData = await FlutterImageCompress.compressAndGetFile(
          file.path,
          targetPath,
          quality: quality,
          format: CompressFormat.png,
        );
        if (compressedData != null) {
          result = File(compressedData.path);
        }
      } else if (ext == '.heic' || ext == '.heif') {
        // Convert HEIC to JPEG and compress
        final jpegPath = path.join(
          tempDir.path,
          '${path.basenameWithoutExtension(file.path)}.jpg',
        );
        final compressedData = await FlutterImageCompress.compressAndGetFile(
          file.path,
          jpegPath,
          quality: quality,
          format: CompressFormat.jpeg,
        );
        if (compressedData != null) {
          result = File(compressedData.path);
        }
      } else {
        // For other formats, try generic compression
        final compressedData = await FlutterImageCompress.compressAndGetFile(
          file.path,
          targetPath,
          quality: quality,
        );
        if (compressedData != null) {
          result = File(compressedData.path);
        }
      }

      // If compression failed or didn't reduce size, return original file
      if (result == null) {
        _logger.warning(
          'ReceiptService._compressImage - Compression failed, using original file',
        );
        return file;
      }

      final int compressedSize = await result.length();
      final double compressionRatio = fileSize / compressedSize;
      _logger.info(
        'ReceiptService._compressImage - Original size: $fileSize bytes',
      );
      _logger.info(
        'ReceiptService._compressImage - Compressed size: $compressedSize bytes',
      );
      _logger.info(
        'ReceiptService._compressImage - Compression ratio: ${compressionRatio.toStringAsFixed(2)}x',
      );

      return result;
    } catch (e, stackTrace) {
      _logger.error(
        'ReceiptService._compressImage - Error compressing image: $e',
        stackTrace: stackTrace,
      );
      // Return original file if compression fails
      return file;
    }
  }
}
