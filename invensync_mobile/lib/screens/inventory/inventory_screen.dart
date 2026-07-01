import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../config/theme.dart';
import '../../providers/data_providers.dart';
import '../../db/database.dart' hide User;

class InventoryScreen extends ConsumerWidget {
  const InventoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = AppTheme.isDark(context);
    final textColor = AppTheme.textColor(context);
    final mutedColor = AppTheme.mutedColor(context);
    final cardColor = AppTheme.cardColor(context);
    final borderColor = AppTheme.borderColor(context);
    final padding = AppTheme.pagePadding(context);

    final productsAsync = ref.watch(productsProvider);
    final products = productsAsync.valueOrNull ?? [];

    final outOfStock = products.where((p) => p.quantity <= 0).toList();
    final lowStock = products.where((p) => p.quantity > 0 && p.quantity <= (p.lowStockThreshold)).toList();
    final healthy = products.where((p) => p.quantity > (p.lowStockThreshold)).toList();
    final totalValue = products.fold<double>(0, (s, p) => s + (p.sellingPrice * p.quantity));

    // Health bar proportions
    final total = products.length.toDouble();
    final healthyPct = total > 0 ? healthy.length / total : 0.0;
    final lowPct = total > 0 ? lowStock.length / total : 0.0;
    final outPct = total > 0 ? outOfStock.length / total : 0.0;

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
                  Text('Inventory', style: AppTheme.heading1.copyWith(color: textColor)),
                  const SizedBox(height: 4),
                  Text('Stock levels & product availability', style: AppTheme.bodySmall.copyWith(color: mutedColor)),
                  const SizedBox(height: 20),

                  // Summary grid 2x2
                  Row(
                    children: [
                      Expanded(child: _summaryCard('Total Value', 'ETB ${totalValue.toStringAsFixed(0)}', Icons.account_balance_wallet_outlined, AppTheme.infoColor, isDark ? AppTheme.infoColor.withValues(alpha: 0.15) : AppTheme.infoBg, cardColor, borderColor, textColor)),
                      const SizedBox(width: 10),
                      Expanded(child: _summaryCard('Total Items', '${products.length}', Icons.category_outlined, AppTheme.primaryColor, isDark ? AppTheme.primaryColor.withValues(alpha: 0.15) : AppTheme.primaryContainer, cardColor, borderColor, textColor)),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(child: _summaryCard('Out of Stock', '${outOfStock.length}', Icons.remove_circle_outline, AppTheme.errorColor, isDark ? AppTheme.errorColor.withValues(alpha: 0.15) : AppTheme.errorBg, cardColor, borderColor, textColor)),
                      const SizedBox(width: 10),
                      Expanded(child: _summaryCard('Low Stock', '${lowStock.length}', Icons.warning_amber_outlined, AppTheme.warningColor, isDark ? AppTheme.warningColor.withValues(alpha: 0.15) : AppTheme.warningBg, cardColor, borderColor, textColor)),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Stock health bar
                  if (products.isNotEmpty) ...[
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Stock Health', style: AppTheme.heading3.copyWith(color: textColor)),
                        Text('${healthy.length} healthy', style: AppTheme.caption.copyWith(color: AppTheme.successColor, fontWeight: FontWeight.w600)),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Container(
                      height: 8,
                      decoration: BoxDecoration(color: isDark ? Colors.white.withValues(alpha: 0.06) : const Color(0xFFF1F5F9), borderRadius: BorderRadius.circular(4)),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: Row(
                          children: [
                            if (healthyPct > 0) Flexible(flex: (healthyPct * 100).round(), child: Container(color: AppTheme.successColor)),
                            if (lowPct > 0) Flexible(flex: (lowPct * 100).round(), child: Container(color: AppTheme.warningColor)),
                            if (outPct > 0) Flexible(flex: (outPct * 100).round(), child: Container(color: AppTheme.errorColor)),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        _legendDot(AppTheme.successColor, 'Healthy'),
                        const SizedBox(width: 12),
                        _legendDot(AppTheme.warningColor, 'Low'),
                        const SizedBox(width: 12),
                        _legendDot(AppTheme.errorColor, 'Out'),
                      ],
                    ),
                    const SizedBox(height: 24),
                  ],
                ]),
              ),
            ),

            // Out of Stock section
            if (outOfStock.isNotEmpty)
              SliverPadding(
                padding: EdgeInsets.fromLTRB(padding.left, 0, padding.right, outOfStock.isNotEmpty && lowStock.isNotEmpty ? 8 : 100),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    _sectionHeader('Out of Stock', outOfStock.length, AppTheme.errorColor, isDark, textColor, mutedColor),
                    const SizedBox(height: 12),
                  ]),
                ),
              ),

            if (outOfStock.isNotEmpty)
              SliverPadding(
                padding: EdgeInsets.fromLTRB(padding.left, 0, padding.right, lowStock.isNotEmpty ? 16 : 100),
                sliver: SliverList.separated(
                  itemCount: outOfStock.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 8),
                  itemBuilder: (context, index) {
                    final p = outOfStock[index];
                    return Padding(
                      padding: EdgeInsets.symmetric(horizontal: padding.horizontal / 2),
                      child: _stockItem(p, AppTheme.errorColor, isDark ? AppTheme.errorColor.withValues(alpha: 0.4) : const Color(0xFFFECACA), '0 units', isDark, textColor, mutedColor, cardColor),
                    );
                  },
                ),
              ),

            // Low Stock section
            if (lowStock.isNotEmpty)
              SliverPadding(
                padding: EdgeInsets.fromLTRB(padding.left, 0, padding.right, 8),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    _sectionHeader('Low Stock', lowStock.length, AppTheme.warningColor, isDark, textColor, mutedColor),
                    const SizedBox(height: 12),
                  ]),
                ),
              ),

            if (lowStock.isNotEmpty)
              SliverPadding(
                padding: EdgeInsets.fromLTRB(padding.left, 0, padding.right, 100),
                sliver: SliverList.separated(
                  itemCount: lowStock.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 8),
                  itemBuilder: (context, index) {
                    final p = lowStock[index];
                    return Padding(
                      padding: EdgeInsets.symmetric(horizontal: padding.horizontal / 2),
                      child: _lowStockItem(p, isDark, textColor, mutedColor, cardColor),
                    );
                  },
                ),
              ),

            // All healthy
            if (outOfStock.isEmpty && lowStock.isEmpty)
              SliverFillRemaining(
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.check_circle_outline, size: 56, color: AppTheme.successColor.withValues(alpha: 0.4)),
                      const SizedBox(height: 16),
                      Text('All stock levels healthy', style: AppTheme.bodyLarge.copyWith(color: mutedColor, fontWeight: FontWeight.w500)),
                      const SizedBox(height: 6),
                      Text('No items need attention right now', style: AppTheme.bodySmall.copyWith(color: mutedColor.withValues(alpha: 0.7))),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _summaryCard(String label, String value, IconData icon, Color iconColor, Color bgColor, Color cardColor, Color borderColor, Color textColor) {
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
          Container(
            width: 36, height: 36,
            decoration: BoxDecoration(color: bgColor, borderRadius: BorderRadius.circular(10)),
            child: Icon(icon, size: 18, color: iconColor),
          ),
          const SizedBox(height: 10),
          Text(label, style: AppTheme.caption.copyWith(color: AppTheme.mutedText)),
          const SizedBox(height: 2),
          Text(value, style: AppTheme.heading2.copyWith(color: textColor, fontSize: 18)),
        ],
      ),
    );
  }

  Widget _sectionHeader(String title, int count, Color color, bool isDark, Color textColor, Color mutedColor) {
    return Row(
      children: [
        Container(width: 4, height: 20, decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(2))),
        const SizedBox(width: 10),
        Text(title, style: AppTheme.heading3.copyWith(color: color)),
        const Spacer(),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
          decoration: BoxDecoration(color: isDark ? color.withValues(alpha: 0.15) : color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8)),
          child: Text('$count items', style: AppTheme.caption.copyWith(color: color, fontWeight: FontWeight.w600)),
        ),
      ],
    );
  }

  Widget _stockItem(Product p, Color accentColor, Color borderColor, String badgeText, bool isDark, Color textColor, Color mutedColor, Color cardColor) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(AppTheme.cardRadius),
        border: Border.all(color: borderColor),
      ),
      child: Row(
        children: [
          Container(
            width: 42, height: 42,
            decoration: BoxDecoration(
              color: isDark ? AppTheme.errorColor.withValues(alpha: 0.15) : AppTheme.errorBg,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.remove_circle_outline, size: 20, color: AppTheme.errorColor),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(p.name, style: AppTheme.bodyLarge.copyWith(color: textColor, fontWeight: FontWeight.w600)),
                if (p.sku != null) ...[
                  const SizedBox(height: 2),
                  Text(p.sku!, style: AppTheme.caption.copyWith(color: mutedColor, fontFamily: 'monospace')),
                ],
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: isDark ? AppTheme.errorColor.withValues(alpha: 0.15) : AppTheme.errorBg,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(badgeText, style: AppTheme.caption.copyWith(color: isDark ? const Color(0xFFFDA4AF) : AppTheme.errorText, fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }

  Widget _lowStockItem(Product p, bool isDark, Color textColor, Color mutedColor, Color cardColor) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(AppTheme.cardRadius),
        border: Border.all(color: isDark ? AppTheme.warningColor.withValues(alpha: 0.4) : const Color(0xFFFDE68A)),
      ),
      child: Row(
        children: [
          Container(
            width: 42, height: 42,
            decoration: BoxDecoration(
              color: isDark ? AppTheme.warningColor.withValues(alpha: 0.15) : AppTheme.warningBg,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.warning_amber_outlined, size: 20, color: AppTheme.warningColor),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(p.name, style: AppTheme.bodyLarge.copyWith(color: textColor, fontWeight: FontWeight.w600)),
                const SizedBox(height: 3),
                Row(
                  children: [
                    Text('${p.quantity} remaining', style: AppTheme.caption.copyWith(color: mutedColor)),
                    Text('  •  ', style: AppTheme.caption.copyWith(color: mutedColor.withValues(alpha: 0.3))),
                    Text('Threshold: ${p.lowStockThreshold}', style: AppTheme.caption.copyWith(color: AppTheme.warningColor)),
                  ],
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: isDark ? AppTheme.warningColor.withValues(alpha: 0.15) : AppTheme.warningBg,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text('${p.quantity}', style: AppTheme.heading3.copyWith(color: isDark ? const Color(0xFFFCD34D) : AppTheme.warningText, fontSize: 16)),
          ),
        ],
      ),
    );
  }

  Widget _legendDot(Color color, String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(width: 8, height: 8, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
        const SizedBox(width: 4),
        Text(label, style: AppTheme.overline.copyWith(color: AppTheme.mutedText, fontSize: 10)),
      ],
    );
  }
}