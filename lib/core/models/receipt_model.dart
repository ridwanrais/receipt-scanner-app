class ReceiptItem {
  final String name;
  final int qty;
  final String price;

  ReceiptItem({
    required this.name,
    required this.qty,
    required this.price,
  });

  factory ReceiptItem.fromJson(Map<String, dynamic> json) {
    return ReceiptItem(
      name: json['name'] as String,
      qty: json['qty'] as int,
      price: json['price'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'qty': qty,
      'price': price,
    };
  }
}

class Receipt {
  final String merchant;
  final String date;
  final String total;
  final String tax;
  final String subtotal;
  final List<ReceiptItem> items;

  Receipt({
    required this.merchant,
    required this.date,
    required this.total,
    required this.tax,
    required this.subtotal,
    required this.items,
  });

  factory Receipt.fromJson(Map<String, dynamic> json) {
    return Receipt(
      merchant: json['merchant'] as String,
      date: json['date'] as String,
      total: json['total'] as String,
      tax: json['tax'] as String,
      subtotal: json['subtotal'] as String,
      items: (json['items'] as List)
          .map((item) => ReceiptItem.fromJson(item as Map<String, dynamic>))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'merchant': merchant,
      'date': date,
      'total': total,
      'tax': tax,
      'subtotal': subtotal,
      'items': items.map((item) => item.toJson()).toList(),
    };
  }
}
