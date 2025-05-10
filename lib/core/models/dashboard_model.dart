class CategoryBreakdown {
  final String category;
  final String amount;
  final double percentage;

  CategoryBreakdown({
    required this.category,
    required this.amount,
    required this.percentage,
  });

  factory CategoryBreakdown.fromJson(Map<String, dynamic> json) {
    return CategoryBreakdown(
      category: json['category'] as String,
      amount: json['amount'] as String,
      percentage: json['percentage'] as double,
    );
  }
}

class MerchantBreakdown {
  final String merchant;
  final String amount;
  final double percentage;

  MerchantBreakdown({
    required this.merchant,
    required this.amount,
    required this.percentage,
  });

  factory MerchantBreakdown.fromJson(Map<String, dynamic> json) {
    return MerchantBreakdown(
      merchant: json['merchant'] as String,
      amount: json['amount'] as String,
      percentage: json['percentage'] as double,
    );
  }
}

class DashboardSummary {
  final String totalSpend;
  final int receiptCount;
  final String averageSpend;
  final List<CategoryBreakdown> topCategories;
  final List<MerchantBreakdown> topMerchants;

  DashboardSummary({
    required this.totalSpend,
    required this.receiptCount,
    required this.averageSpend,
    required this.topCategories,
    required this.topMerchants,
  });

  factory DashboardSummary.fromJson(Map<String, dynamic> json) {
    return DashboardSummary(
      totalSpend: json['totalSpend'] as String,
      receiptCount: json['receiptCount'] as int,
      averageSpend: json['averageSpend'] as String,
      topCategories: (json['topCategories'] as List)
          .map((item) => CategoryBreakdown.fromJson(item as Map<String, dynamic>))
          .toList(),
      topMerchants: (json['topMerchants'] as List)
          .map((item) => MerchantBreakdown.fromJson(item as Map<String, dynamic>))
          .toList(),
    );
  }
}

class SpendingTrendItem {
  final String date;
  final String amount;

  SpendingTrendItem({
    required this.date,
    required this.amount,
  });

  factory SpendingTrendItem.fromJson(Map<String, dynamic> json) {
    return SpendingTrendItem(
      date: json['date'] as String,
      amount: json['amount'] as String,
    );
  }
}

class SpendingTrends {
  final String period;
  final List<SpendingTrendItem> data;

  SpendingTrends({
    required this.period,
    required this.data,
  });

  factory SpendingTrends.fromJson(Map<String, dynamic> json) {
    return SpendingTrends(
      period: json['period'] as String,
      data: (json['data'] as List)
          .map((item) => SpendingTrendItem.fromJson(item as Map<String, dynamic>))
          .toList(),
    );
  }
}

class PaginationInfo {
  final int totalItems;
  final int totalPages;
  final int currentPage;
  final int limit;

  PaginationInfo({
    required this.totalItems,
    required this.totalPages,
    required this.currentPage,
    required this.limit,
  });

  factory PaginationInfo.fromJson(Map<String, dynamic> json) {
    return PaginationInfo(
      totalItems: json['totalItems'] as int,
      totalPages: json['totalPages'] as int,
      currentPage: json['currentPage'] as int,
      limit: json['limit'] as int,
    );
  }
}

class ReceiptListResponse {
  final List<dynamic> data;
  final PaginationInfo pagination;

  ReceiptListResponse({
    required this.data,
    required this.pagination,
  });

  factory ReceiptListResponse.fromJson(Map<String, dynamic> json) {
    return ReceiptListResponse(
      data: json['data'] as List<dynamic>,
      pagination: PaginationInfo.fromJson(json['pagination'] as Map<String, dynamic>),
    );
  }
}
