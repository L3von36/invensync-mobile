import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:drift/drift.dart' hide Column;
import '../../config/theme.dart';
import '../../db/database.dart' hide User;
import '../../utils/currency_formatter.dart';
import '../../utils/date_formatter.dart';
import '../../providers/data_providers.dart';

extension ProductHelpers on Product {
  bool get isLowStock => quantity > 0 && quantity <= lowStockThreshold;
  bool get isOutOfStock => quantity <= 0;
}

extension SaleHelpers on Sale {
  bool get isPaid => amountPaid >= total;
}

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final productsAsync = ref.watch(productsProvider);
    final salesAsync = ref.watch(recentSalesProvider);
    final outboxCount = ref.watch(pendingOutboxCountProvider);
    final isOnlineAsync = ref.watch(isOnlineProvider);
    final isOnline = isOnlineAsync.valueOrNull ?? true;

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // Offline banner
          if (!isOnline)
            SliverToBoxAdapter(
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                color: AppTheme.offlineColor,
                child: const Row(
                  children: [
                    Icon(Icons.wifi_off, color: Colors.white, size: 18),
                    SizedBox(width: 8),
                    Text('Offline - changes will sync when connected',
                        style: TextStyle(color: Colors.white, fontSize: 13)),
                  ],
                ),
              ),
            ),

          // Header
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Dashboard',
                            style: Theme.of(context)
                                .textTheme
                                .headlineSmall
                                ?.copyWith(fontWeight: FontWeight.bold)),
                        const SizedBox(height: 2),
                        Text(_getGreeting(),
                            style: TextStyle(
                                color: Colors.grey.shade600, fontSize: 14)),
                      ],
                    ),
                  ),
                  // Sync status badge
                  if (outboxCount.valueOrNull != null &&
                      outboxCount.valueOrNull! > 0)
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppTheme.warningColor,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        '${outboxCount.valueOrNull} pending',
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.w600),
                      ),
                    ),
                ],
              ),
            ),
          ),

          // Stats grid
          SliverPadding(
            padding: const EdgeInsets.all(16),
            sliver: SliverGrid.count(
              crossAxisCount: 2,
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              childAspectRatio: 1.1,
              children: [
                _StatCard(
                  title: 'Products',
                  value: productsAsync.valueOrNull?.length.toString() ?? '...',
                  icon: Icons.inventory_2_outlined,
                  color: AppTheme.primaryColor,
                  subtitle: 'Total items',
                ),
                _StatCard(
                  title: 'Today Sales',
                  value: _calcTodayRevenue(salesAsync.valueOrNull),
                  icon: Icons.point_of_sale_outlined,
                  color: AppTheme.successColor,
                  subtitle: 'Revenue',
                ),
                _StatCard(
                  title: 'Low Stock',
                  value: _countLowStock(productsAsync.valueOrNull).toString(),
                  icon: Icons.warning_amber_outlined,
                  color: AppTheme.warningColor,
                  subtitle: 'Need attention',
                ),
                _StatCard(
                  title: 'Transactions',
                  value: salesAsync.valueOrNull?.length.toString() ?? '...',
                  icon: Icons.receipt_long_outlined,
                  color: Colors.purple,
                  subtitle: 'Recent sales',
                ),
              ],
            ),
          ),

          // Quick Actions
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text('Quick Actions',
                  style: Theme.of(context)
                      .textTheme
                      .titleMedium
                      ?.copyWith(fontWeight: FontWeight.w600)),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  _QuickAction(
                    icon: Icons.add_shopping_cart_outlined,
                    label: 'New Sale',
                    color: AppTheme.successColor,
                    onTap: () {},
                  ),
                  const SizedBox(width: 12),
                  _QuickAction(
                    icon: Icons.add_box_outlined,
                    label: 'Add Product',
                    color: AppTheme.primaryColor,
                    onTap: () {},
                  ),
                  const SizedBox(width: 12),
                  _QuickAction(
                    icon: Icons.group_add_outlined,
                    label: 'Add Customer',
                    color: Colors.orange,
                    onTap: () {},
                  ),
                  const SizedBox(width: 12),
                  _QuickAction(
                    icon: Icons.swap_vert_outlined,
                    label: 'Stock In',
                    color: Colors.teal,
                    onTap: () {},
                  ),
                ],
              ),
            ),
          ),

          // Recent Sales
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Recent Sales',
                      style: Theme.of(context)
                          .textTheme
                          .titleMedium
                          ?.copyWith(fontWeight: FontWeight.w600)),
                  TextButton(
                    onPressed: () {},
                    child: const Text('View All'),
                  ),
                ],
              ),
            ),
          ),
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                final sale = salesAsync.valueOrNull?[index];
                if (sale == null) return const SizedBox.shrink();
                return _SaleListTile(sale: sale);
              },
              childCount: salesAsync.valueOrNull?.length ?? 0,
            ),
          ),

          // Bottom spacing
          const SliverToBoxAdapter(child: SizedBox(height: 100)),
        ],
      ),
    );
  }

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good Morning';
    if (hour < 17) return 'Good Afternoon';
    return 'Good Evening';
  }

  String _calcTodayRevenue(List<Sale>? sales) {
    if (sales == null || sales.isEmpty) return '0';
    final today = DateTime.now().toIso8601String().substring(0, 10);
    final todaySales = sales.where((s) => s.saleDate.startsWith(today));
    final total = todaySales.fold<double>(0, (sum, s) => sum + s.total);
    return CurrencyFormatter.compact(total);
  }

  int _countLowStock(List<Product>? products) {
    if (products == null) return 0;
    return products.where((p) => p.isLowStock || p.isOutOfStock).length;
  }
}

class _StatCard extends StatelessWidget {
  final String title, value, subtitle;
  final IconData icon;
  final Color color;

  const _StatCard({
    required this.title, required this.value, required this.subtitle,
    required this.icon, required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(icon, color: color, size: 20),
                ),
              ],
            ),
            const Spacer(),
            Text(value,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold, color: color)),
            const SizedBox(height: 2),
            Text(subtitle,
                style: TextStyle(color: Colors.grey.shade600, fontSize: 12)),
            Text(title,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    fontWeight: FontWeight.w600)),
          ],
        ),
      ),
    );
  }
}

class _QuickAction extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _QuickAction({
    required this.icon, required this.label,
    required this.color, required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Material(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Column(
              children: [
                Icon(icon, color: color, size: 24),
                const SizedBox(height: 6),
                Text(label,
                    style: TextStyle(
                        color: color,
                        fontSize: 11,
                        fontWeight: FontWeight.w600)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _SaleListTile extends StatelessWidget {
  final Sale sale;
  const _SaleListTile({required this.sale});

  @override
  Widget build(BuildContext context) {
    final statusColor = sale.status == 'completed'
        ? AppTheme.successColor
        : sale.status == 'cancelled'
            ? AppTheme.errorColor
            : AppTheme.warningColor;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: statusColor.withValues(alpha: 0.1),
          child: Icon(Icons.receipt_outlined, color: statusColor, size: 18),
        ),
        title: Text(sale.invoiceNumber,
            style: const TextStyle(fontWeight: FontWeight.w600)),
        subtitle: Text(
            '${sale.customerName ?? 'Walk-in'} · ${DateFormatter.relative(sale.createdAt)}'),
        trailing: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(CurrencyFormatter.format(sale.total),
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: statusColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(sale.status,
                  style: TextStyle(color: statusColor, fontSize: 10, fontWeight: FontWeight.w600)),
            ),
          ],
        ),
      ),
    );
  }
}