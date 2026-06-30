import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../config/theme.dart';
import '../../db/database.dart';
import '../../utils/currency_formatter.dart';
import '../../utils/date_formatter.dart';
import '../../providers/data_providers.dart';

extension SaleHelpers on Sale {
  bool get isPaid => amountPaid >= total;
}

class SalesScreen extends ConsumerWidget {
  const SalesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final salesAsync = ref.watch(recentSalesProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Sales'),
        actions: [
          IconButton(
            icon: const Icon(Icons.date_range),
            onPressed: () {},
          ),
        ],
      ),
      body: salesAsync.when(
        data: (sales) => sales.isEmpty
            ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.receipt_long_outlined,
                        size: 64, color: Colors.grey.shade300),
                    const SizedBox(height: 16),
                    Text('No sales yet',
                        style: TextStyle(color: Colors.grey.shade600)),
                  ],
                ),
              )
            : RefreshIndicator(
                onRefresh: () => ref.refresh(recentSalesProvider.future),
                child: ListView.separated(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
                  itemCount: sales.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 6),
                  itemBuilder: (context, index) =>
                      _SaleCard(sale: sales[index]),
                ),
              ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, size: 48, color: Colors.grey.shade400),
              const SizedBox(height: 12),
              Text('Failed to load sales',
                  style: TextStyle(color: Colors.grey.shade600)),
              const SizedBox(height: 12),
              FilledButton.tonal(
                onPressed: () => ref.invalidate(recentSalesProvider),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {},
        icon: const Icon(Icons.add_shopping_cart),
        label: const Text('New Sale'),
      ),
    );
  }
}

class _SaleCard extends StatelessWidget {
  final Sale sale;
  const _SaleCard({required this.sale});

  @override
  Widget build(BuildContext context) {
    final statusColor = sale.status == 'completed'
        ? AppTheme.successColor
        : sale.status == 'cancelled'
            ? AppTheme.errorColor
            : AppTheme.warningColor;

    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () {},
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: statusColor.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(sale.status.toUpperCase(),
                            style: TextStyle(
                                color: statusColor,
                                fontSize: 10,
                                fontWeight: FontWeight.w700)),
                      ),
                      const SizedBox(width: 8),
                      Text(sale.invoiceNumber,
                          style: const TextStyle(
                              fontWeight: FontWeight.w600, fontSize: 14)),
                    ],
                  ),
                  Text(CurrencyFormatter.format(sale.total),
                      style: const TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 16)),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(Icons.person_outline, size: 16, color: Colors.grey.shade500),
                  const SizedBox(width: 4),
                  Text(sale.customerName ?? 'Walk-in Customer',
                      style: TextStyle(
                          color: Colors.grey.shade600, fontSize: 13)),
                  const Spacer(),
                  Icon(Icons.access_time, size: 14, color: Colors.grey.shade400),
                  const SizedBox(width: 4),
                  Text(DateFormatter.relative(sale.createdAt),
                      style: TextStyle(
                          color: Colors.grey.shade500, fontSize: 12)),
                ],
              ),
              const SizedBox(height: 6),
              Text(sale.paymentMethod,
                  style: TextStyle(
                      color: Colors.grey.shade400, fontSize: 12)),
            ],
          ),
        ),
      ),
    );
  }
}