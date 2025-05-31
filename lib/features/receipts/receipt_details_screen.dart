import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';

import '../../core/providers/receipt_provider.dart';
import '../../core/models/receipt_model.dart';

class ReceiptDetailsScreen extends StatelessWidget {
  final Receipt receipt;
  final bool isNewScan;

  const ReceiptDetailsScreen({
    super.key,
    required this.receipt,
    this.isNewScan = false,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(receipt.merchant),
        actions: [
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: () {
              final text = _generateReceiptShareText(receipt);
              Share.share(text);
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
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
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
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
            ],
          ],
        ),
      ),
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
