import 'sale.dart';

class DashboardData {
  final DashboardStats stats;
  final DashboardComparison comparison;
  final DashboardPeriod period;
  final List<DashboardAnomaly> anomalies;
  final List<Sale> recentSales;
  final List<TopProduct> topProducts;
  final List<SalesTrendPoint> salesTrend;

  const DashboardData({
    required this.stats, required this.comparison,
    required this.period, required this.anomalies,
    required this.recentSales, required this.topProducts,
    required this.salesTrend,
  });

  factory DashboardData.fromJson(Map<String, dynamic> json) {
    return DashboardData(
      stats: DashboardStats.fromJson(
          (json['stats'] as Map<String, dynamic>?) ?? {}),
      comparison: DashboardComparison.fromJson(
          (json['comparison'] as Map<String, dynamic>?) ?? {}),
      period: DashboardPeriod.fromJson(
          (json['period'] as Map<String, dynamic>?) ?? {}),
      anomalies: (json['anomalies'] as List<dynamic>?)
              ?.map((e) =>
                  DashboardAnomaly.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      recentSales: (json['recentSales'] as List<dynamic>?)
              ?.map((e) => Sale.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      topProducts: (json['topProducts'] as List<dynamic>?)
              ?.map((e) => TopProduct.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      salesTrend: (json['salesTrend'] as List<dynamic>?)
              ?.map((e) =>
                  SalesTrendPoint.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }
}

class DashboardStats {
  final int totalProducts;
  final int outOfStockCount;
  final int lowStockCount;
  final double totalStockCostValue;
  final double totalStockRetailValue;
  final double todayRevenue;
  final int todaySalesCount;
  final double monthRevenue;
  final double totalCustomerDebt;
  final double periodRevenue;
  final double periodExpenses;
  final double periodCogs;
  final double periodNetProfit;
  final int periodSalesCount;

  const DashboardStats({
    this.totalProducts = 0, this.outOfStockCount = 0,
    this.lowStockCount = 0, this.totalStockCostValue = 0,
    this.totalStockRetailValue = 0, this.todayRevenue = 0,
    this.todaySalesCount = 0, this.monthRevenue = 0,
    this.totalCustomerDebt = 0, this.periodRevenue = 0,
    this.periodExpenses = 0, this.periodCogs = 0,
    this.periodNetProfit = 0, this.periodSalesCount = 0,
  });

  factory DashboardStats.fromJson(Map<String, dynamic> json) {
    return DashboardStats(
      totalProducts: (json['totalProducts'] as num?)?.toInt() ?? 0,
      outOfStockCount: (json['outOfStockCount'] as num?)?.toInt() ?? 0,
      lowStockCount: (json['lowStockCount'] as num?)?.toInt() ?? 0,
      totalStockCostValue:
          (json['totalStockCostValue'] as num?)?.toDouble() ?? 0,
      totalStockRetailValue:
          (json['totalStockRetailValue'] as num?)?.toDouble() ?? 0,
      todayRevenue: (json['todayRevenue'] as num?)?.toDouble() ?? 0,
      todaySalesCount: (json['todaySalesCount'] as num?)?.toInt() ?? 0,
      monthRevenue: (json['monthRevenue'] as num?)?.toDouble() ?? 0,
      totalCustomerDebt:
          (json['totalCustomerDebt'] as num?)?.toDouble() ?? 0,
      periodRevenue: (json['periodRevenue'] as num?)?.toDouble() ?? 0,
      periodExpenses: (json['periodExpenses'] as num?)?.toDouble() ?? 0,
      periodCogs: (json['periodCogs'] as num?)?.toDouble() ?? 0,
      periodNetProfit: (json['periodNetProfit'] as num?)?.toDouble() ?? 0,
      periodSalesCount: (json['periodSalesCount'] as num?)?.toInt() ?? 0,
    );
  }
}

class DashboardComparison {
  final double revenueChange;
  final double expenseChange;
  final double netProfitChange;
  final double salesCountChange;
  final double prevRevenue;
  final double prevExpenses;
  final double prevNetProfit;
  final int prevSalesCount;

  const DashboardComparison({
    this.revenueChange = 0, this.expenseChange = 0,
    this.netProfitChange = 0, this.salesCountChange = 0,
    this.prevRevenue = 0, this.prevExpenses = 0,
    this.prevNetProfit = 0, this.prevSalesCount = 0,
  });

  factory DashboardComparison.fromJson(Map<String, dynamic> json) {
    return DashboardComparison(
      revenueChange: (json['revenueChange'] as num?)?.toDouble() ?? 0,
      expenseChange: (json['expenseChange'] as num?)?.toDouble() ?? 0,
      netProfitChange: (json['netProfitChange'] as num?)?.toDouble() ?? 0,
      salesCountChange: (json['salesCountChange'] as num?)?.toDouble() ?? 0,
      prevRevenue: (json['prevRevenue'] as num?)?.toDouble() ?? 0,
      prevExpenses: (json['prevExpenses'] as num?)?.toDouble() ?? 0,
      prevNetProfit: (json['prevNetProfit'] as num?)?.toDouble() ?? 0,
      prevSalesCount: (json['prevSalesCount'] as num?)?.toInt() ?? 0,
    );
  }
}

class DashboardPeriod {
  final String from;
  final String to;
  final String prevFrom;
  final String prevTo;

  const DashboardPeriod({
    this.from = '', this.to = '', this.prevFrom = '', this.prevTo = '',
  });

  factory DashboardPeriod.fromJson(Map<String, dynamic> json) {
    return DashboardPeriod(
      from: json['from'] as String? ?? '',
      to: json['to'] as String? ?? '',
      prevFrom: json['prevFrom'] as String? ?? '',
      prevTo: json['prevTo'] as String? ?? '',
    );
  }
}

class DashboardAnomaly {
  final String id;
  final String type;
  final String message;
  final String severity;

  const DashboardAnomaly({
    required this.id, required this.type,
    required this.message, required this.severity,
  });

  factory DashboardAnomaly.fromJson(Map<String, dynamic> json) {
    return DashboardAnomaly(
      id: json['id'] as String? ?? '',
      type: json['type'] as String? ?? '',
      message: json['message'] as String? ?? '',
      severity: json['severity'] as String? ?? '',
    );
  }
}

class TopProduct {
  final String id;
  final String name;
  final String? sku;
  final String? imageUrl;
  final double totalRevenue;
  final int totalQuantity;

  const TopProduct({
    required this.id, required this.name, this.sku,
    this.imageUrl, required this.totalRevenue,
    required this.totalQuantity,
  });

  factory TopProduct.fromJson(Map<String, dynamic> json) {
    return TopProduct(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      sku: json['sku'] as String?,
      imageUrl: json['imageUrl'] as String?,
      totalRevenue: (json['totalRevenue'] as num?)?.toDouble() ?? 0,
      totalQuantity: (json['totalQuantity'] as num?)?.toInt() ?? 0,
    );
  }
}

class SalesTrendPoint {
  final String date;
  final double revenue;

  const SalesTrendPoint({required this.date, required this.revenue});

  factory SalesTrendPoint.fromJson(Map<String, dynamic> json) {
    return SalesTrendPoint(
      date: json['date'] as String? ?? '',
      revenue: (json['revenue'] as num?)?.toDouble() ?? 0,
    );
  }
}