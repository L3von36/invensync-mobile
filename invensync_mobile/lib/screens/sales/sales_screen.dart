import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../config/theme.dart';
import '../../providers/data_providers.dart';
import '../../db/database.dart' hide User;

class SalesScreen extends ConsumerWidget {
  const SalesScreen({super.key});

  String _formatCurrency(double amount) => 'ETB ${amount.toStringAsFixed(2)}';

  String _relativeTime(String dateStr) {
    try {
      final date = DateTime.parse(dateStr);
      final diff = DateTime.now().difference(date);
      if (diff.inMinutes < 1) return 'Just now';
      if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
      if (diff.inHours < 24) return '${diff.inHours}h ago';
      if (diff.inDays == 1) return 'Yesterday';
      if (diff.inDays < 7) return '${diff.inDays}d ago';
      return '${date.day}/${date.month}';
    } catch (_) {
      return '';
    }
  }

  Color _statusBg(String status, bool isDark) {
    switch (status) {
      case 'completed':
        return isDark
            ? AppTheme.successColor.withValues(alpha: 0.15)
            : AppTheme.successBg;
      case 'pending':
        return isDark
            ? AppTheme.warningColor.withValues(alpha: 0.15)
            : AppTheme.warningBg;
      case 'cancelled':
        return isDark
            ? AppTheme.errorColor.withValues(alpha: 0.15)
            : AppTheme.errorBg;
      default:
        return isDark
            ? Colors.white.withValues(alpha: 0.08)
            : const Color(0xFFF1F5F9);
    }
  }

  Color _statusTextColor(String status, bool isDark) {
    switch (status) {
      case 'completed':
        return isDark
            ? const Color(0xFF6EE7B7)
            : AppTheme.successText;
      case 'pending':
        return isDark ? const Color(0xFFFCD34D) : AppTheme.warningText;
      case 'cancelled':
        return isDark ? const Color(0xFFFDA4AF) : AppTheme.errorText;
      default:
        return AppTheme.mutedText;
    }
  }

  Color _statusDotColor(String status) {
    switch (status) {
      case 'completed': return AppTheme.successColor;
      case 'pending': return AppTheme.warningColor;
      case 'cancelled': return AppTheme.errorColor;
      default: return AppTheme.mutedText;
    }
  }

  IconData _paymentIcon(String? method) {
    switch (method) {
      case 'card': return Icons.credit_card_outlined;
      case 'mobile': return Icons.phone_android_outlined;
      default: return Icons.payments_outlined;
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = AppTheme.isDark(context);
    final textColor = AppTheme.textColor(context);
    final mutedColor = AppTheme.mutedColor(context);
    final cardColor = AppTheme.cardColor(context);
    final borderColor = AppTheme.borderColor(context);
    final padding = AppTheme.pagePadding(context);

    final salesAsync = ref.watch(recentSalesProvider);
    final sales = salesAsync.valueOrNull ?? [];

    // Stats calculations
    final today = DateTime.now();
    final todayStr = today.toIso8601String().substring(0, 10);
    final weekAgo = today.subtract(const Duration(days: 7));

    final todaySales = sales.where((s) => s.createdAt.startsWith(todayStr)).toList();
    final weekSales = sales.where((s) {
      try { return DateTime.parse(s.createdAt).isAfter(weekAgo); } catch (_) { return false; }
    }).toList();
    final avgSale = sales.isNotEmpty ? sales.fold<double>(0, (s, sale) => s + sale.total) / sales.length : 0.0;
    final todayTotal = todaySales.fold<double>(0, (s, sale) => s + sale.total);
    final weekTotal = weekSales.fold<double>(0, (s, sale) => s + sale.total);

    return Scaffold(
      body: RefreshIndicator(
        onRefresh: () async {},
        color: AppTheme.primaryColor,
        backgroundColor: cardColor,
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            SliverPadding(
              padding: padding,
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  // Header
                  Text('Sales', style: AppTheme.heading1.copyWith(color: textColor)),
                  const SizedBox(height: 4),
                  Text('${sales.length} transactions', style: AppTheme.bodySmall.copyWith(color: mutedColor)),
                  const SizedBox(height: 20),

                  // Stats row
                  Row(
                    children: [
                      Expanded(child: _miniStat('Today', _formatCurrency(todayTotal), Icons.today_outlined, AppTheme.successColor, isDark ? AppTheme.successColor.withValues(alpha: 0.15) : AppTheme.successBg, cardColor, borderColor, textColor)),
                      const SizedBox(width: 10),
                      Expanded(child: _miniStat('This Week', _formatCurrency(weekTotal), Icons.date_range_outlined, AppTheme.infoColor, isDark ? AppTheme.infoColor.withValues(alpha: 0.15) : AppTheme.infoBg, cardColor, borderColor, textColor)),
                      const SizedBox(width: 10),
                      Expanded(child: _miniStat('Avg. Value', _formatCurrency(avgSale), Icons.trending_up_outlined, AppTheme.primaryColor, isDark ? AppTheme.primaryColor.withValues(alpha: 0.15) : AppTheme.primaryContainer, cardColor, borderColor, textColor)),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Section header
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('All Transactions', style: AppTheme.heading3.copyWith(color: textColor)),
                      TextButton(
                        onPressed: () {},
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                          minimumSize: Size.zero, tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                        child: Text('View All', style: AppTheme.caption.copyWith(color: AppTheme.primaryColor, fontWeight: FontWeight.w600)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                ]),
              ),
            ),

            if (sales.isEmpty)
              SliverFillRemaining(
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.receipt_long_outlined, size: 56, color: mutedColor.withValues(alpha: 0.3)),
                      const SizedBox(height: 16),
                      Text('No sales recorded', style: AppTheme.bodyLarge.copyWith(color: mutedColor, fontWeight: FontWeight.w500)),
                      const SizedBox(height: 6),
                      Text('Completed sales will appear here', style: AppTheme.bodySmall.copyWith(color: mutedColor.withValues(alpha: 0.7))),
                    ],
                  ),
                ),
              )
            else
              SliverPadding(
                padding: EdgeInsets.fromLTRB(
                  padding.left, 0, padding.right, 100,
                ),
                sliver: SliverList.separated(
                  itemCount: sales.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 8),
                  itemBuilder: (context, index) {
                    final sale = sales[index];
                    final status = sale.status ?? 'completed';
                    return _buildSaleCard(context, sale, status, isDark, textColor, mutedColor, cardColor, borderColor);
                  },
                ),
              ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AppTheme.primaryColor,
        foregroundColor: Colors.white,
        onPressed: () {},
        icon: const Icon(Icons.receipt_long_rounded, size: 20),
        label: const Text('New Sale', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
        shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(16))),
        elevation: 4,
      ),
    );
  }

  Widget _buildSaleCard(BuildContext context, Sale sale, String status, bool isDark, Color textColor, Color mutedColor, Color cardColor, Color borderColor) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(AppTheme.cardRadius),
        border: Border.all(color: borderColor),
        boxShadow: isDark ? null : AppTheme.shadowCard,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Top: invoice + status
          Row(
            children: [
              Container(width: 10, height: 10, decoration: BoxDecoration(color: _statusDotColor(status), shape: BoxShape.circle)),
              const SizedBox(width: 10),
              Text(sale.invoiceNumber, style: AppTheme.caption.copyWith(fontFamily: 'monospace', fontWeight: FontWeight.w700, color: textColor, letterSpacing: -0.3)),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                decoration: BoxDecoration(color: _statusBg(status, isDark), borderRadius: BorderRadius.circular(8)),
                child: Text(status.toUpperCase(), style: AppTheme.overline.copyWith(color: _statusTextColor(status, isDark))),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Customer + time
          Row(
            children: [
              Expanded(
                child: Text(sale.customerName ?? 'Walk-in Customer', style: AppTheme.bodyLarge.copyWith(color: textColor, fontWeight: FontWeight.w500), overflow: TextOverflow.ellipsis),
              ),
              const SizedBox(width: 12),
              Text(_relativeTime(sale.createdAt), style: AppTheme.bodySmall.copyWith(color: mutedColor)),
            ],
          ),
          const SizedBox(height: 14),
          // Bottom: payment + amount
          const Divider(height: 1),
          const SizedBox(height: 12),
          Row(
            children: [
              Icon(_paymentIcon(sale.paymentMethod), size: 15, color: mutedColor),
              const SizedBox(width: 6),
              Text((sale.paymentMethod ?? 'cash').replaceAll('_', ' ').toUpperCase(), style: AppTheme.caption.copyWith(color: mutedColor, fontWeight: FontWeight.w500)),
              const Spacer(),
              Text(_formatCurrency(sale.total), style: AppTheme.heading3.copyWith(color: textColor, letterSpacing: -0.3)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _miniStat(String label, String value, IconData icon, Color iconColor, Color bgColor, Color cardColor, Color borderColor, Color textColor) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(AppTheme.cardRadiusSm),
        border: Border.all(color: borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 32, height: 32,
                decoration: BoxDecoration(color: bgColor, borderRadius: BorderRadius.circular(8)),
                child: Icon(icon, size: 16, color: iconColor),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(label, style: AppTheme.caption.copyWith(color: AppTheme.mutedText)),
          const SizedBox(height: 2),
          Text(value, style: AppTheme.heading2.copyWith(color: textColor, fontSize: 18), overflow: TextOverflow.ellipsis),
        ],
      ),
    );
  }
}