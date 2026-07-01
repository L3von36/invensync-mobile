import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../config/theme.dart';
import '../../providers/data_providers.dart';
import '../../db/database.dart' hide User;

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  // ─────────────────────────────────────────────
  // HELPERS
  // ─────────────────────────────────────────────

  String _formatCurrency(double amount) {
    return 'ETB ${amount.toStringAsFixed(2)}';
  }

  String _relativeTime(String dateStr) {
    try {
      final date = DateTime.parse(dateStr);
      final now = DateTime.now();
      final diff = now.difference(date);
      if (diff.inMinutes < 1) return 'Just now';
      if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
      if (diff.inHours < 24) return '${diff.inHours}h ago';
      if (diff.inDays == 1) return 'Yesterday';
      if (diff.inDays < 7) return '${diff.inDays}d ago';
      return '${date.day}/${date.month}/${date.year}';
    } catch (_) {
      return '';
    }
  }

  Color _statusColor(String status) {
    switch (status) {
      case 'completed':
        return AppTheme.successColor;
      case 'pending':
        return AppTheme.warningColor;
      case 'cancelled':
        return AppTheme.errorColor;
      default:
        return AppTheme.mutedText;
    }
  }

  Color _statusBg(String status, BuildContext context) {
    final isDark = AppTheme.isDark(context);
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

  Color _statusText(String status, BuildContext context) {
    final isDark = AppTheme.isDark(context);
    switch (status) {
      case 'completed':
        return isDark ? const Color(0xFF6EE7B7) : AppTheme.successText;
      case 'pending':
        return isDark ? const Color(0xFFFCD34D) : AppTheme.warningText;
      case 'cancelled':
        return isDark ? const Color(0xFFFCA5A5) : AppTheme.errorText;
      default:
        return AppTheme.mutedText;
    }
  }

  String _formattedDate() {
    final now = DateTime.now();
    const weekdays = [
      'Monday',
      'Tuesday',
      'Wednesday',
      'Thursday',
      'Friday',
      'Saturday',
      'Sunday',
    ];
    const months = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December',
    ];
    return '${weekdays[now.weekday - 1]}, ${months[now.month - 1]} ${now.day}, ${now.year}';
  }

  // ─────────────────────────────────────────────
  // BUILD
  // ─────────────────────────────────────────────

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authStateProvider);
    final productsAsync = ref.watch(productsProvider);
    final salesAsync = ref.watch(recentSalesProvider);

    final user = authState.valueOrNull?.user;
    final products = productsAsync.valueOrNull ?? [];
    final sales = salesAsync.valueOrNull ?? [];

    final totalProducts = products.length;
    final lowStockCount =
        products.where((p) => p.quantity > 0 && p.quantity <= p.lowStockThreshold).length;
    final outOfStock = products.where((p) => p.quantity <= 0).length;
    final todayDate = DateTime.now().toIso8601String().substring(0, 10);
    final todaySales = sales.where((s) => s.createdAt.startsWith(todayDate)).toList();
    final todayRevenue =
        todaySales.fold<double>(0, (sum, s) => sum + s.total);
    final totalSales = sales.length;

    return Scaffold(
      body: RefreshIndicator(
        onRefresh: () async {},
        color: AppTheme.primaryColor,
        backgroundColor: AppTheme.cardColor(context),
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: AppTheme.pagePadding(context).copyWith(top: 20, bottom: 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Header ──────────────────────────
              _buildHeader(context, user?.name),
              const SizedBox(height: 24),

              // ── Revenue Card ────────────────────
              _buildRevenueCard(context, todayRevenue, totalSales),
              const SizedBox(height: 20),

              // ── Stats Grid ──────────────────────
              _buildStatsGrid(
                context,
                totalProducts: totalProducts,
                lowStockCount: lowStockCount,
                totalSales: totalSales,
                outOfStock: outOfStock,
              ),
              const SizedBox(height: 28),

              // ── Quick Actions ───────────────────
              _buildQuickActionsSection(context),
              const SizedBox(height: 28),

              // ── Recent Sales ────────────────────
              _buildRecentSalesSection(context, sales),
            ],
          ),
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────
  // HEADER
  // ─────────────────────────────────────────────

  Widget _buildHeader(BuildContext context, String? userName) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Dashboard',
          style: AppTheme.heading1.copyWith(
            color: AppTheme.textColor(context),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          userName != null ? 'Welcome back, $userName' : 'Welcome back',
          style: AppTheme.bodySmall.copyWith(
            color: AppTheme.mutedColor(context),
          ),
        ),
        const SizedBox(height: 6),
        Text(
          _formattedDate(),
          style: AppTheme.bodySmall.copyWith(
            color: AppTheme.mutedColor(context).withValues(alpha: 0.7),
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  // ─────────────────────────────────────────────
  // REVENUE CARD
  // ─────────────────────────────────────────────

  Widget _buildRevenueCard(
    BuildContext context,
    double revenue,
    int salesCount,
  ) {
    final isDark = AppTheme.isDark(context);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 20),
      decoration: BoxDecoration(
        gradient: isDark
            ? const LinearGradient(
                colors: [Color(0xFF1E293B), Color(0xFF334155)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              )
            : AppTheme.primaryGradient,
        borderRadius: BorderRadius.circular(18),
        boxShadow: AppTheme.shadowPrimary,
      ),
      child: Stack(
        children: [
          // Decorative circles
          Positioned(
            right: -20,
            top: -20,
            child: Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isDark
                    ? Colors.white.withValues(alpha: 0.04)
                    : Colors.white.withValues(alpha: 0.15),
              ),
            ),
          ),
          Positioned(
            right: 30,
            bottom: -30,
            child: Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isDark
                    ? Colors.white.withValues(alpha: 0.03)
                    : Colors.white.withValues(alpha: 0.1),
              ),
            ),
          ),
          // Content
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Today's Revenue",
                style: AppTheme.bodySmall.copyWith(
                  color: isDark
                      ? const Color(0xFF94A3B8)
                      : Colors.white.withValues(alpha: 0.85),
                  fontWeight: FontWeight.w500,
                  fontSize: 13,
                  letterSpacing: 0.2,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                _formatCurrency(revenue),
                style: const TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                  letterSpacing: -0.8,
                  height: 1.2,
                ),
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Icon(
                    Icons.receipt_long_rounded,
                    size: 16,
                    color: isDark
                        ? const Color(0xFF94A3B8)
                        : Colors.white.withValues(alpha: 0.7),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    '$salesCount sale${salesCount != 1 ? 's' : ''} today',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: isDark
                          ? const Color(0xFF94A3B8)
                          : Colors.white.withValues(alpha: 0.75),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────
  // STATS GRID
  // ─────────────────────────────────────────────

  Widget _buildStatsGrid(
    BuildContext context, {
    required int totalProducts,
    required int lowStockCount,
    required int totalSales,
    required int outOfStock,
  }) {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 12,
      crossAxisSpacing: 12,
      childAspectRatio: 1.8,
      children: [
        _buildStatCard(
          context,
          icon: Icons.inventory_2_outlined,
          label: 'Total Products',
          value: '$totalProducts',
          iconBgColor: AppTheme.infoColor,
        ),
        _buildStatCard(
          context,
          icon: Icons.warning_amber_rounded,
          label: 'Low Stock',
          value: '$lowStockCount',
          iconBgColor: AppTheme.warningColor,
          subtitle: outOfStock > 0 ? '$outOfStock out of stock' : null,
        ),
        _buildStatCard(
          context,
          icon: Icons.shopping_bag_outlined,
          label: 'Total Sales',
          value: '$totalSales',
          iconBgColor: AppTheme.successColor,
        ),
        _buildStatCard(
          context,
          icon: Icons.cancel_outlined,
          label: 'Out of Stock',
          value: '$outOfStock',
          iconBgColor: AppTheme.errorColor,
        ),
      ],
    );
  }

  Widget _buildStatCard(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String value,
    required Color iconBgColor,
    String? subtitle,
  }) {
    final isDark = AppTheme.isDark(context);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.cardColor(context),
        borderRadius: BorderRadius.circular(AppTheme.cardRadiusSm),
        border: Border.all(color: AppTheme.borderColor(context)),
        boxShadow: AppTheme.shadowCard,
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  label,
                  style: AppTheme.caption.copyWith(
                    color: AppTheme.mutedColor(context),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: AppTheme.heading2.copyWith(
                    color: AppTheme.textColor(context),
                  ),
                ),
                if (subtitle != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: AppTheme.caption.copyWith(
                      color: AppTheme.errorColor,
                      fontSize: 11,
                    ),
                  ),
                ],
              ],
            ),
          ),
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: isDark
                  ? iconBgColor.withValues(alpha: 0.15)
                  : iconBgColor.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, size: 20, color: iconBgColor),
          ),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────
  // QUICK ACTIONS
  // ─────────────────────────────────────────────

  Widget _buildQuickActionsSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Quick Actions',
          style: AppTheme.heading3.copyWith(
            color: AppTheme.textColor(context),
          ),
        ),
        const SizedBox(height: 14),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          clipBehavior: Clip.none,
          child: Row(
            children: [
              _buildQuickAction(
                context,
                icon: Icons.receipt_long_rounded,
                label: 'New Sale',
                isPrimary: true,
              ),
              const SizedBox(width: 12),
              _buildQuickAction(
                context,
                icon: Icons.add_box_outlined,
                label: 'Add Product',
              ),
              const SizedBox(width: 12),
              _buildQuickAction(
                context,
                icon: Icons.person_add_outlined,
                label: 'Add Customer',
              ),
              const SizedBox(width: 12),
              _buildQuickAction(
                context,
                icon: Icons.inventory_outlined,
                label: 'Stock In',
              ),
              const SizedBox(width: 4),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildQuickAction(
    BuildContext context, {
    required IconData icon,
    required String label,
    bool isPrimary = false,
  }) {
    final isDark = AppTheme.isDark(context);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 64,
          height: 64,
          decoration: BoxDecoration(
            color: isPrimary
                ? AppTheme.primaryColor
                : isDark
                    ? const Color(0xFF334155)
                    : AppTheme.surfaceLight,
            borderRadius: BorderRadius.circular(16),
            boxShadow: isPrimary ? AppTheme.shadowPrimary : AppTheme.shadowSm,
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(16),
              onTap: () {},
              child: Center(
                child: Icon(
                  icon,
                  size: 26,
                  color: isPrimary ? Colors.white : AppTheme.primaryColor,
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 8),
        SizedBox(
          width: 72,
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: AppTheme.caption.copyWith(
              color: isPrimary
                  ? AppTheme.primaryColor
                  : AppTheme.mutedColor(context),
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }

  // ─────────────────────────────────────────────
  // RECENT SALES
  // ─────────────────────────────────────────────

  Widget _buildRecentSalesSection(BuildContext context, List<Sale> sales) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Recent Sales',
              style: AppTheme.heading3.copyWith(
                color: AppTheme.textColor(context),
              ),
            ),
            TextButton(
              onPressed: () {},
              style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              child: Text(
                'View All',
                style: AppTheme.caption.copyWith(
                  color: AppTheme.primaryColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        if (sales.isEmpty)
          _buildEmptyState(
            context,
            icon: Icons.receipt_long_outlined,
            title: 'No sales yet',
            subtitle: 'Sales will appear here once you make transactions',
          )
        else
          ...sales.take(5).map(
            (sale) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: _buildSaleCard(context, sale),
            ),
          ),
      ],
    );
  }

  Widget _buildSaleCard(BuildContext context, Sale sale) {
    final status = sale.status;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.cardColor(context),
        borderRadius: BorderRadius.circular(AppTheme.cardRadius),
        border: Border.all(color: AppTheme.borderColor(context)),
      ),
      child: Row(
        children: [
          // Status dot
          Container(
            width: 10,
            height: 10,
            decoration: BoxDecoration(
              color: _statusColor(status),
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 14),
          // Middle content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      sale.invoiceNumber,
                      style: AppTheme.caption.copyWith(
                        fontWeight: FontWeight.w700,
                        fontFamily: 'monospace',
                        letterSpacing: -0.2,
                        color: AppTheme.textColor(context),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 2.5,
                      ),
                      decoration: BoxDecoration(
                        color: _statusBg(status, context),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        status.toUpperCase(),
                        style: AppTheme.overline.copyWith(
                          color: _statusText(status, context),
                          fontSize: 9,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  sale.customerName ?? 'Walk-in',
                  style: AppTheme.bodyLarge.copyWith(
                    color: AppTheme.textColor(context),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  _relativeTime(sale.createdAt),
                  style: AppTheme.bodySmall.copyWith(
                    color: AppTheme.mutedColor(context),
                  ),
                ),
              ],
            ),
          ),
          // Amount
          Text(
            _formatCurrency(sale.total),
            style: AppTheme.heading3.copyWith(
              color: AppTheme.textColor(context),
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────
  // EMPTY STATE
  // ─────────────────────────────────────────────

  Widget _buildEmptyState(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 48),
      child: Center(
        child: Column(
          children: [
            Icon(
              icon,
              size: 56,
              color: AppTheme.mutedColor(context).withValues(alpha: 0.3),
            ),
            const SizedBox(height: 16),
            Text(
              title,
              style: AppTheme.bodyLarge.copyWith(
                color: AppTheme.mutedColor(context),
              ),
            ),
            const SizedBox(height: 6),
            Text(
              subtitle,
              style: AppTheme.bodySmall.copyWith(
                color: AppTheme.mutedColor(context).withValues(alpha: 0.6),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}