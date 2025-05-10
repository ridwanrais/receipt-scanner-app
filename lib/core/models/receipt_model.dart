class ReceiptItem {
  final String name;
  final int qty;
  final String price;
  final String? id;
  final String? category;

  ReceiptItem({
    required this.name,
    required this.qty,
    required this.price,
    this.id,
    this.category,
  });

  factory ReceiptItem.fromJson(Map<String, dynamic> json) {
    return ReceiptItem(
      name: json['name'] as String,
      qty: json['qty'] is int ? json['qty'] : int.parse(json['qty'].toString()),
      price: json['price'] as String,
      id: json['id'] as String?,
      category: json['category'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'qty': qty,
      'price': price,
      if (id != null) 'id': id,
      if (category != null) 'category': category,
    };
  }
}

class Receipt {
  final String? id;
  final String merchant;
  final String date;
  final String total;
  final String tax;
  final String subtotal;
  final List<ReceiptItem> items;
  final String? createdAt;
  final String? updatedAt;

  Receipt({
    this.id,
    required this.merchant,
    required this.date,
    required this.total,
    required this.tax,
    required this.subtotal,
    required this.items,
    this.createdAt,
    this.updatedAt,
  });

  factory Receipt.fromJson(Map<String, dynamic> json) {
    return Receipt(
      id: json['id'] as String?,
      merchant: json['merchant'] as String,
      date: json['date'] as String,
      total: json['total'] as String,
      tax: json['tax'] as String,
      subtotal: json['subtotal'] as String,
      items: (json['items'] as List)
          .map((item) => ReceiptItem.fromJson(item as Map<String, dynamic>))
          .toList(),
      createdAt: json['createdAt'] as String?,
      updatedAt: json['updatedAt'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'merchant': merchant,
      'date': date,
      'total': total,
      'tax': tax,
      'subtotal': subtotal,
      'items': items.map((item) => item.toJson()).toList(),
      if (createdAt != null) 'createdAt': createdAt,
      if (updatedAt != null) 'updatedAt': updatedAt,
    };
  }
}
