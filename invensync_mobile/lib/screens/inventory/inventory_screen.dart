import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:drift/drift.dart' hide Column;
import '../../config/theme.dart';
import '../../db/database.dart' hide User;
import '../../utils/currency_formatter.dart';
import '../../providers/data_providers.dart';

extension ProductHelpers on Product {
  bool get isLowStock => quantity > 0 && quantity <= lowStockThreshold;
  bool get isOutOfStock => quantity <= 0;
}

extension CustomerHelpers on Customer {
  int get salesCount => 0;
}

class InventoryScreen extends ConsumerWidget {
  const InventoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final productsAsync = ref.watch(productsProvider);
    final allProducts = productsAsync.valueOrNull ?? [];

    final outOfStock = allProducts.where((p) => p.isOutOfStock).toList();
    final lowStock = allProducts.where((p) => p.isLowStock && !p.isOutOfStock).toList();
    final healthy = allProducts.where((p) => !p.isLowStock && !p.isOutOfStock).toList();
    final totalCostValue = allProducts.fold<double>(
        0, (sum, p) => sum + (p.costPrice * p.quantity));
    final totalRetailValue = allProducts.fold<double>(
        0, (sum, p) => sum + (p.sellingPrice * p.quantity));

    return Scaffold(
      appBar: AppBar(title: const Text('Inventory')),
      body: RefreshIndicator(
        onRefresh: () => ref.refresh(productsProvider.future),
        child: CustomScrollView(
          slivers: [
            // Summary cards
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: _SummaryCard(
                            label: 'Total Value',
                            value: CurrencyFormatter.format(totalRetailValue),
                            subtitle:
                                'Cost: ${CurrencyFormatter.format(totalCostValue)}',
                            icon: Icons.assessment_outlined,
                            color: AppTheme.primaryColor,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _SummaryCard(
                            label: 'Total Items',
                            value: allProducts.length.toString(),
                            subtitle: '${healthy.length} healthy',
                            icon: Icons.inventory_2_outlined,
                            color: AppTheme.successColor,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: _SummaryCard(
                            label: 'Out of Stock',
                            value: outOfStock.length.toString(),
                            subtitle: 'Need reorder',
                            icon: Icons.cancel_outlined,
                            color: AppTheme.errorColor,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _SummaryCard(
                            label: 'Low Stock',
                            value: lowStock.length.toString(),
                            subtitle: 'Below threshold',
                            icon: Icons.warning_amber_outlined,
                            color: AppTheme.warningColor,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            // Out of Stock section
            if (outOfStock.isNotEmpty) ...[
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
                  child: Row(
                    children: [
                      Icon(Icons.error_outline, color: AppTheme.errorColor, size: 18),
                      const SizedBox(width: 6),
                      Text('Out of Stock',
                          style: TextStyle(
                              color: AppTheme.errorColor,
                              fontWeight: FontWeight.w600,
                              fontSize: 15)),
                    ],
                  ),
                ),
              ),
              SliverList(
                delegate: SliverChildBuilderDelegate(
                  (ctx, i) => _StockTile(product: outOfStock[i]),
                  childCount: outOfStock.length,
                ),
              ),
            ],

            // Low Stock section
            if (lowStock.isNotEmpty) ...[
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
                  child: Row(
                    children: [
                      Icon(Icons.warning_amber_outlined,
                          color: AppTheme.warningColor, size: 18),
                      const SizedBox(width: 6),
                      Text('Low Stock',
                          style: TextStyle(
                              color: AppTheme.warningColor,
                              fontWeight: FontWeight.w600,
                              fontSize: 15)),
                    ],
                  ),
                ),
              ),
              SliverList(
                delegate: SliverChildBuilderDelegate(
                  (ctx, i) => _StockTile(product: lowStock[i]),
                  childCount: lowStock.length,
                ),
              ),
            ],

            // All products
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
                child: Text('All Products (${allProducts.length})',
                    style: const TextStyle(
                        fontWeight: FontWeight.w600, fontSize: 15)),
              ),
            ),
            SliverList(
              delegate: SliverChildBuilderDelegate(
                (ctx, i) => _StockTile(product: allProducts[i]),
                childCount: allProducts.length,
              ),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: 100)),
          ],
        ),
      ),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  final String label, value, subtitle;
  final IconData icon;
  final Color color;

  const _SummaryCard({
    required this.label, required this.value, required this.subtitle,
    required this.icon, required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: color, size: 18),
                const SizedBox(width: 6),
                Text(label,
                    style: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: 12,
                        fontWeight: FontWeight.w500)),
              ],
            ),
            const SizedBox(height: 8),
            Text(value,
                style: TextStyle(
                    color: color, fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 2),
            Text(subtitle,
                style: TextStyle(color: Colors.grey.shade500, fontSize: 11)),
          ],
        ),
      ),
    );
  }
}

class _StockTile extends StatelessWidget {
  final Product product;
  const _StockTile({required this.product});

  @override
  Widget build(BuildContext context) {
    final stockColor = product.isOutOfStock
        ? AppTheme.errorColor
        : product.isLowStock
            ? AppTheme.warningColor
            : AppTheme.successColor;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 3),
      child: ListTile(
        dense: true,
        title: Text(product.name,
            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
        subtitle: Text(
            '${product.productTypeId} · ${product.sku ?? 'No SKU'}',
            style: TextStyle(color: Colors.grey.shade500, fontSize: 12)),
        trailing: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text('${product.quantity}',
                style: TextStyle(
                    color: stockColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 16)),
            Text('qty', style: TextStyle(color: Colors.grey.shade400, fontSize: 10)),
          ],
        ),
        onTap: () {},
      ),
    );
  }
}