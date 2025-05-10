class SpendingItemInfo {
  final String name;
  final String totalSpent;
  final int count;

  SpendingItemInfo({
    required this.name,
    required this.totalSpent,
    required this.count,
  });

  factory SpendingItemInfo.fromJson(Map<String, dynamic> json) {
    return SpendingItemInfo(
      name: json['name'] as String,
      totalSpent: json['totalSpent'] as String,
      count: json['count'] as int,
    );
  }
}

class CategorySpendingInfo {
  final String name;
  final String amount;
  final double percentage;
  final List<SpendingItemInfo> items;

  CategorySpendingInfo({
    required this.name,
    required this.amount,
    required this.percentage,
    required this.items,
  });

  factory CategorySpendingInfo.fromJson(Map<String, dynamic> json) {
    return CategorySpendingInfo(
      name: json['name'] as String,
      amount: json['amount'] as String,
      percentage: json['percentage'] as double,
      items: (json['items'] as List)
          .map((item) => SpendingItemInfo.fromJson(item as Map<String, dynamic>))
          .toList(),
    );
  }
}

class SpendingByCategory {
  final String total;
  final List<CategorySpendingInfo> categories;

  SpendingByCategory({
    required this.total,
    required this.categories,
  });

  factory SpendingByCategory.fromJson(Map<String, dynamic> json) {
    return SpendingByCategory(
      total: json['total'] as String,
      categories: (json['categories'] as List)
          .map((item) => CategorySpendingInfo.fromJson(item as Map<String, dynamic>))
          .toList(),
    );
  }
}

class MerchantFrequencyItem {
  final String name;
  final int visits;
  final String totalSpent;
  final String averageSpent;
  final double percentage;

  MerchantFrequencyItem({
    required this.name,
    required this.visits,
    required this.totalSpent,
    required this.averageSpent,
    required this.percentage,
  });

  factory MerchantFrequencyItem.fromJson(Map<String, dynamic> json) {
    return MerchantFrequencyItem(
      name: json['name'] as String,
      visits: json['visits'] as int,
      totalSpent: json['totalSpent'] as String,
      averageSpent: json['averageSpent'] as String,
      percentage: json['percentage'] as double,
    );
  }
}

class MerchantFrequency {
  final int totalVisits;
  final List<MerchantFrequencyItem> merchants;

  MerchantFrequency({
    required this.totalVisits,
    required this.merchants,
  });

  factory MerchantFrequency.fromJson(Map<String, dynamic> json) {
    return MerchantFrequency(
      totalVisits: json['totalVisits'] as int,
      merchants: (json['merchants'] as List)
          .map((item) => MerchantFrequencyItem.fromJson(item as Map<String, dynamic>))
          .toList(),
    );
  }
}

class CategoryComparisonItem {
  final String name;
  final String month1Amount;
  final String month2Amount;
  final String difference;
  final double percentageChange;

  CategoryComparisonItem({
    required this.name,
    required this.month1Amount,
    required this.month2Amount,
    required this.difference,
    required this.percentageChange,
  });

  factory CategoryComparisonItem.fromJson(Map<String, dynamic> json) {
    return CategoryComparisonItem(
      name: json['name'] as String,
      month1Amount: json['month1Amount'] as String,
      month2Amount: json['month2Amount'] as String,
      difference: json['difference'] as String,
      percentageChange: json['percentageChange'] as double,
    );
  }
}

class MonthlyComparison {
  final String month1;
  final String month2;
  final String month1Total;
  final String month2Total;
  final String difference;
  final double percentageChange;
  final List<CategoryComparisonItem> categories;

  MonthlyComparison({
    required this.month1,
    required this.month2,
    required this.month1Total,
    required this.month2Total,
    required this.difference,
    required this.percentageChange,
    required this.categories,
  });

  factory MonthlyComparison.fromJson(Map<String, dynamic> json) {
    return MonthlyComparison(
      month1: json['month1'] as String,
      month2: json['month2'] as String,
      month1Total: json['month1Total'] as String,
      month2Total: json['month2Total'] as String,
      difference: json['difference'] as String,
      percentageChange: json['percentageChange'] as double,
      categories: (json['categories'] as List)
          .map((item) => CategoryComparisonItem.fromJson(item as Map<String, dynamic>))
          .toList(),
    );
  }
}
