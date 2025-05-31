import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:camera/camera.dart';

import '../../core/services/logger.dart';

import '../../core/providers/receipt_provider.dart';
import '../../core/models/receipt_model.dart';
import 'camera_screen.dart';
import 'receipt_details_screen.dart';

class ReceiptsScreen extends StatefulWidget {
  const ReceiptsScreen({super.key});

  @override
  State<ReceiptsScreen> createState() => _ReceiptsScreenState();
}

class _ReceiptsScreenState extends State<ReceiptsScreen> {
  final Logger _logger = Logger();
  bool _processingImage = false;
  bool _isLoading = false;
  late ReceiptProvider _receiptProvider;

  @override
  void initState() {
    super.initState();
    _initializeLogger();
  }
  
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Get the provider reference when dependencies change
    _receiptProvider = Provider.of<ReceiptProvider>(context, listen: false);
  }

  Future<void> _initializeLogger() async {
    await _logger.initialize();
    _logger.info('ReceiptsScreen initialized');
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Scaffold(
          appBar: AppBar(
            title: const Text(
              'My Receipts',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.search),
                onPressed: () {
                  // Search feature would be implemented here
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Search will be implemented soon')),
                  );
                },
              ),
            ],
          ),
      body: Consumer<ReceiptProvider>(
        builder: (context, provider, _) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (provider.error != null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(provider.error!),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => provider.fetchReceipts(),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          if (provider.receipts.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.receipt_long_outlined,
                    size: 80,
                    color: Colors.grey,
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'No receipts yet',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Add your first receipt by tapping the + button',
                    style: TextStyle(color: Colors.grey),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    onPressed: () => _showAddReceiptOptions(context),
                    icon: const Icon(Icons.add),
                    label: const Text('Add Receipt'),
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () => provider.fetchReceipts(),
            child: ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: provider.receipts.length,
              separatorBuilder: (context, index) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final receipt = provider.receipts[index];
                return _buildReceiptCard(context, receipt);
              },
            ),
          );
        },
      ),
          floatingActionButton: FloatingActionButton(
            onPressed: () => _showAddReceiptOptions(context),
            child: const Icon(Icons.add),
          ),
        ),
        // Overlay loading indicator when processing
        if (_isLoading)
          Container(
            color: Colors.black.withOpacity(0.5),
            child: const Center(
              child: CircularProgressIndicator(),
            ),
          ),
      ],
    );
  }

  Widget _buildReceiptCard(BuildContext context, Receipt receipt) {
    return Card(
      elevation: 0,
      child: InkWell(
        onTap: () => _showReceiptDetails(context, receipt),
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      receipt.merchant,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Text(
                    receipt.total,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                'Date: ${receipt.date}',
                style: TextStyle(
                  color: Colors.grey.shade700,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                '${receipt.items.length} items',
                style: TextStyle(
                  color: Colors.grey.shade700,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showAddReceiptOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 16.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Add Receipt',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                ListTile(
                  leading: CircleAvatar(
                    backgroundColor: Theme.of(context).colorScheme.primaryContainer,
                    child: Icon(
                      Icons.camera_alt,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                  title: const Text('Take a Picture'),
                  onTap: () {
                    Navigator.pop(context);
                    _openCamera(context);
                  },
                ),
                ListTile(
                  leading: CircleAvatar(
                    backgroundColor: Theme.of(context).colorScheme.primaryContainer,
                    child: Icon(
                      Icons.photo_library,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                  title: const Text('Choose from Gallery'),
                  onTap: () {
                    Navigator.pop(context);
                    _pickImage(context);
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _openCamera(BuildContext context) async {
    try {
      if (_processingImage) {
        _logger.info('Already processing an image, ignoring request');
        return;
      }
      
      final cameras = await availableCameras();
      _logger.info('Available cameras: ${cameras.map((c) => c.name).join(', ')}');
      
      final firstCamera = cameras.first;
      
      if (!mounted) {
        _logger.info('Widget not mounted before navigation');
        return;
      }
      
      // ignore: use_build_context_synchronously
      final result = await Navigator.of(context).push<File>(
        MaterialPageRoute(
          builder: (context) => CameraScreen(camera: firstCamera),
        ),
      );

      _logger.info('Result from camera: $result');
      
      // Check mounted state again after navigation
      if (!mounted) {
        _logger.info('Widget not mounted after navigation');
        return;
      }
      
      if (result != null) {
        _logger.info('Processing receipt image');
        // Create a safe local copy of the context and verify it's valid
        final BuildContext? contextToUse = context;
        if (contextToUse != null && mounted) {
          // ignore: use_build_context_synchronously
          await _processReceiptImage(contextToUse, result);
        } else {
          _logger.error('Cannot process image: invalid context state');
        }
      } else {
        _logger.info('No image selected');
      }
    } catch (e, stackTrace) {
      _logger.error('Error in _openCamera: $e', stackTrace: stackTrace);
      if (mounted) {
        _showErrorSnackBar(context, 'Failed to open camera: $e');
      }
    }
  }

  Future<void> _pickImage(BuildContext context) async {
    try {
      if (_processingImage) {
        _logger.info('Already processing an image, ignoring request');
        return;
      }
      
      final imagePicker = ImagePicker();
      _logger.info('Opening image picker');
      final pickedFile = await imagePicker.pickImage(source: ImageSource.gallery);
      
      if (pickedFile == null) {
        _logger.info('No image selected');
        return;
      }
      
      final imageFile = File(pickedFile.path);
      _logger.info('Image picked: ${imageFile.path}');
      
      if (!mounted) {
        _logger.info('Widget not mounted after picking image');
        return;
      }
      
      _logger.info('Processing picked image');
      await _processReceiptImage(context, imageFile);
    } catch (e, stackTrace) {
      _logger.error('Error picking image', stackTrace: stackTrace);
      
      if (mounted) {
        _showErrorSnackBar(context, 'Error picking image: $e');
      }
    }
  }

  Future<void> _processReceiptImage(BuildContext context, File imageFile) async {
    if (!mounted) {
      _logger.info('Widget not mounted at start of _processReceiptImage');
      return;
    }
    
    // Set processing flag
    setState(() {
      _processingImage = true;
    });
    
    try {
      _logger.info('Processing receipt image: ${imageFile.path}');
      _logger.info('Image exists: ${await imageFile.exists()}');
      _logger.info('Image size: ${await imageFile.length()} bytes');
      
      if (!mounted) return;
      
      // Show loading indicator in the current screen instead of a dialog
      setState(() {
        _isLoading = true; // Add this field to the state class
      });
      _logger.info('Set loading state to true');
      
      // Scan the receipt
      _logger.info('Scanning receipt...');
      await _receiptProvider.scanReceipt(imageFile);
      _logger.info('Scan completed. Receipt: ${_receiptProvider.currentReceipt != null ? "Success" : "Null"}');
      _logger.info('Error: ${_receiptProvider.error}');
      
      // We need to check mounted again after async operation
      if (!mounted) {
        _logger.info('Widget not mounted after scanning receipt');
        return;
      }
      
      // Hide loading indicator
      setState(() {
        _isLoading = false;
      });
      _logger.info('Set loading state to false');
      
      // Navigate to receipt details if successful
      if (_receiptProvider.currentReceipt != null) {
        _logger.info('Navigating to receipt details screen');
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => ReceiptDetailsScreen(
              receipt: _receiptProvider.currentReceipt!,
              isNewScan: true,
            ),
          ),
        );
      } else if (_receiptProvider.error != null) {
        _logger.info('Showing error from provider: ${_receiptProvider.error}');
        _showErrorSnackBar(context, _receiptProvider.error!);
      } else {
        _logger.info('No receipt and no error - showing generic error');
        _showErrorSnackBar(context, 'Failed to process receipt. Please try again.');
      }
    } catch (e, stackTrace) {
      _logger.error('Error processing receipt', stackTrace: stackTrace);
      
      if (mounted) {
        try {
          // Set loading state to false first
          setState(() {
            _isLoading = false;
          });
          
          // Safely check if we can access the navigator
          final BuildContext? contextToUse = context;
          if (contextToUse != null && contextToUse.mounted) {
            // Show the error message
            _logger.info('Showing error snackbar');
            _showErrorSnackBar(contextToUse, 'Failed to process receipt: $e');
          }
        } catch (navError) {
          // If we can't access the navigator, just log it
          _logger.error('Navigation error after processing receipt', stackTrace: StackTrace.current);
        }
      } else {
        _logger.info('Cannot show error: widget not mounted');
      }
    } finally {
      if (mounted) {
        setState(() {
          _processingImage = false;
        });
      }
    }
  }

  // Loading indicator is now handled directly in the build method

  void _showErrorSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  void _showReceiptDetails(BuildContext context, Receipt receipt, {bool isNewScan = false}) {
    if (!context.mounted) return;
    
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => ReceiptDetailsScreen(
          receipt: receipt,
          isNewScan: isNewScan,
        ),
      ),
    );
  }
}
