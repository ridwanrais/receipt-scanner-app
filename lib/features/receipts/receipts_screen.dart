import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:camera/camera.dart';
import 'package:share_plus/share_plus.dart';

import '../../core/providers/receipt_provider.dart';
import '../../core/models/receipt_model.dart';
import 'camera_screen.dart';

class ReceiptsScreen extends StatelessWidget {
  const ReceiptsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
      final cameras = await availableCameras();
      if (cameras.isEmpty) {
        _showErrorSnackBar(context, 'No camera found');
        return;
      }
      
      final firstCamera = cameras.first;
      
      if (!context.mounted) return;
      
      // ignore: use_build_context_synchronously
      final result = await Navigator.of(context).push<File>(
        MaterialPageRoute(
          builder: (context) => CameraScreen(camera: firstCamera),
        ),
      );
      
      if (result != null && context.mounted) {
        // ignore: use_build_context_synchronously
        _processReceiptImage(context, result);
      }
    } catch (e) {
      _showErrorSnackBar(context, 'Error accessing camera: $e');
    }
  }

  Future<void> _pickImage(BuildContext context) async {
    try {
      final imagePicker = ImagePicker();
      final pickedFile = await imagePicker.pickImage(source: ImageSource.gallery);
      
      if (pickedFile == null) return;
      
      final imageFile = File(pickedFile.path);
      if (context.mounted) {
        _processReceiptImage(context, imageFile);
      }
    } catch (e) {
      _showErrorSnackBar(context, 'Error picking image: $e');
    }
  }

  void _processReceiptImage(BuildContext context, File imageFile) {
    final provider = Provider.of<ReceiptProvider>(context, listen: false);
    provider.scanReceipt(imageFile).then((_) {
      if (provider.currentReceipt != null) {
        _showReceiptDetails(context, provider.currentReceipt!, isNewScan: true);
      }
    });
  }

  void _showErrorSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  void _showReceiptDetails(BuildContext context, Receipt receipt, {bool isNewScan = false}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.9,
          maxChildSize: 0.95,
          minChildSize: 0.5,
          expand: false,
          builder: (context, scrollController) {
            return Container(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          receipt.merchant,
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () {
                          Navigator.pop(context);
                        },
                      ),
                    ],
                  ),
                  Text(
                    'Date: ${receipt.date}',
                    style: TextStyle(
                      color: Colors.grey.shade700,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 24),
                  _buildReceiptAmounts(receipt),
                  const SizedBox(height: 16),
                  const Divider(),
                  const SizedBox(height: 8),
                  const Text(
                    'Items',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Expanded(
                    child: ListView.separated(
                      controller: scrollController,
                      itemCount: receipt.items.length,
                      separatorBuilder: (context, index) => const Divider(),
                      itemBuilder: (context, index) {
                        final item = receipt.items[index];
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8.0),
                          child: Row(
                            children: [
                              Expanded(
                                flex: 3,
                                child: Text(
                                  item.name,
                                  style: const TextStyle(
                                    fontSize: 16,
                                  ),
                                ),
                              ),
                              Expanded(
                                flex: 1,
                                child: Text(
                                  'x${item.qty}',
                                  style: const TextStyle(fontSize: 16),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                              Expanded(
                                flex: 2,
                                child: Text(
                                  item.price,
                                  style: const TextStyle(fontSize: 16),
                                  textAlign: TextAlign.end,
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                  if (isNewScan) ...[
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () {
                              Navigator.pop(context);
                              Provider.of<ReceiptProvider>(context, listen: false)
                                  .saveCurrentReceipt();
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Receipt saved successfully'),
                                ),
                              );
                            },
                            icon: const Icon(Icons.save),
                            label: const Text('Save Receipt'),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () {
                              final text = _generateReceiptShareText(receipt);
                              Share.share(text);
                            },
                            icon: const Icon(Icons.share),
                            label: const Text('Share'),
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildReceiptAmounts(Receipt receipt) {
    return Row(
      children: [
        Expanded(
          child: _buildAmountCard('Subtotal', receipt.subtotal),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildAmountCard('Tax', receipt.tax),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildAmountCard('Total', receipt.total, isHighlighted: true),
        ),
      ],
    );
  }

  Widget _buildAmountCard(String label, String amount, {bool isHighlighted = false}) {
    return Card(
      elevation: 0,
      color: isHighlighted
          ? Colors.greenAccent.withOpacity(0.2)
          : Colors.grey.withOpacity(0.1),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 8.0),
        child: Column(
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey.shade700,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              amount,
              style: TextStyle(
                fontSize: 16,
                fontWeight: isHighlighted ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _generateReceiptShareText(Receipt receipt) {
    final buffer = StringBuffer();
    buffer.writeln('Receipt from ${receipt.merchant}');
    buffer.writeln('Date: ${receipt.date}');
    buffer.writeln('');
    buffer.writeln('Items:');
    for (final item in receipt.items) {
      buffer.writeln('${item.name} (x${item.qty}) - ${item.price}');
    }
    buffer.writeln('');
    buffer.writeln('Subtotal: ${receipt.subtotal}');
    buffer.writeln('Tax: ${receipt.tax}');
    buffer.writeln('Total: ${receipt.total}');
    buffer.writeln('');
    buffer.writeln('Generated by Receipt AI Scanner App');
    return buffer.toString();
  }
}
