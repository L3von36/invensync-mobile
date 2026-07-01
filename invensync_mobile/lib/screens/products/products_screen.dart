import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../config/theme.dart';
import '../../providers/data_providers.dart';
import '../../db/database.dart' hide User;

class ProductsScreen extends ConsumerStatefulWidget {
  const ProductsScreen({super.key});

  @override
  ConsumerState<ProductsScreen> createState() => _ProductsScreenState();
}

class _ProductsScreenState extends ConsumerState<ProductsScreen> {
  String _searchQuery = '';
  String _filter = 'all'; // all, low_stock, out_of_stock, active

  // ── Helpers ──────────────────────────────────────────────────────────────

  String _formatPrice(double price) {
    return 'ETB ${price.toStringAsFixed(2)}';
  }

  Color _stockColor(int qty) {
    if (qty <= 0) return AppTheme.errorColor;
    if (qty <= 10) return AppTheme.warningColor;
    return AppTheme.successColor;
  }

  String _stockLabel(int qty) {
    if (qty <= 0) return 'Out of stock';
    if (qty <= 10) return 'Low stock';
    return 'In stock';
  }

  Color _stockBg(int qty, bool isDark) {
    if (qty <= 0) {
      return isDark
          ? AppTheme.errorColor.withValues(alpha: 0.15)
          : AppTheme.errorBg;
    }
    if (qty <= 10) {
      return isDark
          ? AppTheme.warningColor.withValues(alpha: 0.15)
          : AppTheme.warningBg;
    }
    return isDark
        ? AppTheme.successColor.withValues(alpha: 0.15)
        : AppTheme.successBg;
  }

  Color _stockText(int qty, bool isDark) {
    if (qty <= 0) return isDark ? const Color(0xFFFDA4AF) : AppTheme.errorText;
    if (qty <= 10) return isDark ? const Color(0xFFFCD34D) : AppTheme.warningText;
    return isDark ? const Color(0xFF6EE7B7) : AppTheme.successText;
  }

  // ── Refresh ──────────────────────────────────────────────────────────────

  Future<void> _refresh() async {
    ref.invalidate(productsProvider);
  }

  // ── Build ───────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final isDark = AppTheme.isDark(context);
    final textColor = AppTheme.textColor(context);
    final mutedColor = AppTheme.mutedColor(context);
    final cardColor = AppTheme.cardColor(context);
    final borderColor = AppTheme.borderColor(context);
    final scaffoldBg = AppTheme.scaffoldBg(context);
    final padding = AppTheme.pagePadding(context);

    final productsAsync = ref.watch(productsProvider);
    final products = productsAsync.valueOrNull ?? [];

    final filtered = products.where((p) {
      // Filter
      if (_filter == 'low_stock' && p.quantity > 10) return false;
      if (_filter == 'out_of_stock' && p.quantity > 0) return false;
      if (_filter == 'active' && p.isActive != true) return false;
      // Search
      if (_searchQuery.isNotEmpty) {
        final q = _searchQuery.toLowerCase();
        return p.name.toLowerCase().contains(q) ||
            (p.sku?.toLowerCase().contains(q) ?? false);
      }
      return true;
    }).toList();

    return Scaffold(
      backgroundColor: scaffoldBg,
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AppTheme.primaryColor,
        foregroundColor: AppTheme.onPrimary,
        onPressed: () {},
        icon: const Icon(Icons.add_rounded),
        label: const Text(
          'Add Product',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: Colors.white,
            fontSize: 14,
            letterSpacing: 0.2,
          ),
        ),
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
      body: RefreshIndicator(
        color: AppTheme.primaryColor,
        backgroundColor: cardColor,
        strokeWidth: 2.5,
        onRefresh: _refresh,
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            // ── Top safe area + header ────────────────────────────────
            SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.only(
                  left: padding.left,
                  right: padding.right,
                  top: padding.top + 8,
                  bottom: 0,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header
                    Text(
                      'Products',
                      style: AppTheme.heading1.copyWith(color: textColor),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${products.length} products in catalog',
                      style: AppTheme.bodySmall.copyWith(color: mutedColor),
                    ),
                    const SizedBox(height: 20),

                    // ── Search bar ──────────────────────────────────────
                    TextField(
                      onChanged: (v) => setState(() => _searchQuery = v),
                      style: AppTheme.bodyMedium.copyWith(color: textColor),
                      cursorColor: AppTheme.primaryColor,
                      decoration: InputDecoration(
                        hintText: 'Search products by name or SKU...',
                        hintStyle: AppTheme.bodyMedium.copyWith(
                          color: mutedColor,
                        ),
                        prefixIcon: Icon(
                          Icons.search_rounded,
                          color: mutedColor,
                          size: AppTheme.iconSizeMd,
                        ),
                        suffixIcon: _searchQuery.isNotEmpty
                            ? IconButton(
                                icon: Icon(
                                  Icons.close_rounded,
                                  color: mutedColor,
                                  size: AppTheme.iconSizeMd,
                                ),
                                onPressed: () =>
                                    setState(() => _searchQuery = ''),
                              )
                            : null,
                        filled: true,
                        fillColor:
                            isDark ? AppTheme.surfaceDark : AppTheme.surfaceLight,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 12,
                        ),
                        border: OutlineInputBorder(
                          borderRadius:
                              BorderRadius.circular(AppTheme.inputRadius),
                          borderSide: BorderSide(color: borderColor),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius:
                              BorderRadius.circular(AppTheme.inputRadius),
                          borderSide: BorderSide(color: borderColor),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius:
                              BorderRadius.circular(AppTheme.inputRadius),
                          borderSide: const BorderSide(
                            color: AppTheme.primaryColor,
                            width: 1.5,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),

                    // ── Filter chips ────────────────────────────────────
                    SizedBox(
                      height: 36,
                      child: ListView(
                        scrollDirection: Axis.horizontal,
                        padding: EdgeInsets.zero,
                        children: [
                          _buildFilterChip(
                            label: 'All',
                            value: 'all',
                            isDark: isDark,
                            mutedColor: mutedColor,
                          ),
                          const SizedBox(width: 8),
                          _buildFilterChip(
                            label: 'Active',
                            value: 'active',
                            isDark: isDark,
                            mutedColor: mutedColor,
                          ),
                          const SizedBox(width: 8),
                          _buildFilterChip(
                            label: 'Low Stock',
                            value: 'low_stock',
                            isDark: isDark,
                            mutedColor: mutedColor,
                          ),
                          const SizedBox(width: 8),
                          _buildFilterChip(
                            label: 'Out of Stock',
                            value: 'out_of_stock',
                            isDark: isDark,
                            mutedColor: mutedColor,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ),

            // ── Product list or empty state ─────────────────────────────
            if (filtered.isEmpty)
              SliverFillRemaining(
                hasScrollBody: false,
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 64),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.inventory_2_outlined,
                          size: 56,
                          color: mutedColor.withValues(alpha: 0.3),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No products found',
                          style: AppTheme.bodyLarge.copyWith(color: mutedColor),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'Add your first product to get started',
                          style: AppTheme.bodySmall.copyWith(
                            color: mutedColor.withValues(alpha: 0.7),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              )
            else
              SliverPadding(
                padding: EdgeInsets.symmetric(horizontal: padding.left),
                sliver: SliverList.separated(
                  itemCount: filtered.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 8),
                  itemBuilder: (context, index) =>
                      _buildProductCard(filtered[index], isDark),
                ),
              ),

            // ── Bottom spacing for FAB ──────────────────────────────────
            const SliverToBoxAdapter(
              child: SizedBox(height: 88),
            ),
          ],
        ),
      ),
    );
  }

  // ── Product card ─────────────────────────────────────────────────────────

  Widget _buildProductCard(Product p, bool isDark) {
    final textColor = AppTheme.textColor(context);
    final mutedColor = AppTheme.mutedColor(context);
    final cardColor = AppTheme.cardColor(context);
    final borderColor = AppTheme.borderColor(context);
    final iconBgColor =
        isDark ? AppTheme.surfaceDark : const Color(0xFFF1F5F9);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(AppTheme.cardRadius),
        border: Border.all(color: borderColor),
        boxShadow: isDark ? null : AppTheme.shadowCard,
      ),
      child: Row(
        children: [
          // ── Icon ──────────────────────────────────────────────────
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: iconBgColor,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              Icons.inventory_2_outlined,
              size: 24,
              color: mutedColor.withValues(alpha: 0.6),
            ),
          ),
          const SizedBox(width: 14),

          // ── Name + SKU ───────────────────────────────────────────
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  p.name,
                  style: AppTheme.bodyLarge.copyWith(
                    fontWeight: FontWeight.w600,
                    color: textColor,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                if (p.sku != null && p.sku!.isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Text(
                    p.sku!,
                    style: AppTheme.caption.copyWith(
                      color: mutedColor,
                      fontFamily: 'monospace',
                      letterSpacing: 0.3,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ],
            ),
          ),

          // ── Price + Stock badge ────────────────────────────────────
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                _formatPrice(p.sellingPrice),
                style: AppTheme.heading3.copyWith(
                  fontWeight: FontWeight.w700,
                  color: textColor,
                ),
              ),
              const SizedBox(height: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                decoration: BoxDecoration(
                  color: _stockBg(p.quantity, isDark),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '${p.quantity} ${_stockLabel(p.quantity)}',
                  style: AppTheme.overline.copyWith(
                    fontWeight: FontWeight.w600,
                    color: _stockText(p.quantity, isDark),
                    fontSize: 10.5,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ── Filter chip ──────────────────────────────────────────────────────────

  Widget _buildFilterChip({
    required String label,
    required String value,
    required bool isDark,
    required Color mutedColor,
  }) {
    final active = _filter == value;
    final chipBorderColor =
        active ? AppTheme.primaryColor : (isDark ? Colors.white.withValues(alpha: 0.12) : AppTheme.borderLight);

    return FilterChip(
      selected: active,
      showCheckmark: false,
      label: Text(label, style: TextStyle(
        fontSize: 13,
        fontWeight: active ? FontWeight.w600 : FontWeight.w500,
        color: active ? AppTheme.primaryColor : mutedColor,
      )),
      onSelected: (_) => setState(() => _filter = value),
      selectedColor: AppTheme.primaryColor.withValues(alpha: 0.1),
      side: BorderSide(color: chipBorderColor),
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
      visualDensity: VisualDensity.compact,
    );
  }
}
