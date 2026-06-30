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

extension SaleHelpers on Sale {
  bool get isPaid => amountPaid >= total;
}

class ProductsScreen extends ConsumerStatefulWidget {
  const ProductsScreen({super.key});

  @override
  ConsumerState<ProductsScreen> createState() => _ProductsScreenState();
}

class _ProductsScreenState extends ConsumerState<ProductsScreen> {
  final _searchController = TextEditingController();
  String _searchQuery = '';
  String? _filterStatus;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final productsAsync = ref.watch(productsProvider);
    final allProducts = productsAsync.valueOrNull ?? [];

    var filtered = allProducts.where((p) {
      final matchesSearch = _searchQuery.isEmpty ||
          p.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          (p.sku?.toLowerCase().contains(_searchQuery.toLowerCase()) ?? false);
      final matchesFilter = _filterStatus == null ||
          (_filterStatus == 'low' && p.isLowStock) ||
          (_filterStatus == 'out' && p.isOutOfStock) ||
          (_filterStatus == 'active' && p.isActive);
      return matchesSearch && matchesFilter;
    }).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Products'),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: _showFilterSheet,
          ),
          IconButton(
            icon: const Icon(Icons.qr_code_scanner),
            onPressed: () {},
          ),
        ],
      ),
      body: Column(
        children: [
          // Search bar
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _searchController,
              onChanged: (v) => setState(() => _searchQuery = v),
              decoration: InputDecoration(
                hintText: 'Search products...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          setState(() => _searchQuery = '');
                        },
                      )
                    : null,
              ),
            ),
          ),

          // Filter chips
          if (_filterStatus != null)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  Chip(
                    label: Text(_filterStatus == 'low'
                        ? 'Low Stock'
                        : _filterStatus == 'out'
                            ? 'Out of Stock'
                            : 'Active'),
                    deleteIcon: const Icon(Icons.close, size: 16),
                    onDeleted: () => setState(() => _filterStatus = null),
                    backgroundColor: _filterStatus == 'out'
                        ? AppTheme.errorColor.withValues(alpha: 0.1)
                        : _filterStatus == 'low'
                            ? AppTheme.warningColor.withValues(alpha: 0.1)
                            : AppTheme.successColor.withValues(alpha: 0.1),
                    labelStyle: TextStyle(
                      color: _filterStatus == 'out'
                          ? AppTheme.errorColor
                          : _filterStatus == 'low'
                              ? AppTheme.warningColor
                              : AppTheme.successColor,
                      fontWeight: FontWeight.w600,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),

          // Products list
          Expanded(
            child: filtered.isEmpty
                ? _EmptyState(
                    isSearching: _searchQuery.isNotEmpty,
                    onRefresh: () => ref.invalidate(productsProvider))
                : RefreshIndicator(
                    onRefresh: () => ref.refresh(productsProvider.future),
                    child: ListView.builder(
                      padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
                      itemCount: filtered.length,
                      itemBuilder: (context, index) =>
                          _ProductCard(product: filtered[index]),
                    ),
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {},
        icon: const Icon(Icons.add),
        label: const Text('Add Product'),
      ),
    );
  }

  void _showFilterSheet() {
    showModalBottomSheet(
      context: context,
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.check_box_outline_blank),
              title: const Text('All Products'),
              onTap: () {
                setState(() => _filterStatus = null);
                Navigator.pop(ctx);
              },
            ),
            ListTile(
              leading: Icon(Icons.warning_amber_outlined,
                  color: AppTheme.warningColor),
              title: const Text('Low Stock'),
              onTap: () {
                setState(() => _filterStatus = 'low');
                Navigator.pop(ctx);
              },
            ),
            ListTile(
              leading: Icon(Icons.cancel_outlined, color: AppTheme.errorColor),
              title: const Text('Out of Stock'),
              onTap: () {
                setState(() => _filterStatus = 'out');
                Navigator.pop(ctx);
              },
            ),
            ListTile(
              leading:
                  Icon(Icons.check_circle_outlined, color: AppTheme.successColor),
              title: const Text('Active Only'),
              onTap: () {
                setState(() => _filterStatus = 'active');
                Navigator.pop(ctx);
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _ProductCard extends StatelessWidget {
  final Product product;
  const _ProductCard({required this.product});

  @override
  Widget build(BuildContext context) {
    final stockColor = product.isOutOfStock
        ? AppTheme.errorColor
        : product.isLowStock
            ? AppTheme.warningColor
            : AppTheme.successColor;

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () {},
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              // Product image or placeholder
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: product.imageUrl != null && product.imageUrl!.isNotEmpty
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: Image.network(product.imageUrl!,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => const Icon(
                                Icons.inventory_2_outlined,
                                color: Colors.grey)),
                      )
                    : const Icon(Icons.inventory_2_outlined, color: Colors.grey),
              ),
              const SizedBox(width: 12),

              // Product info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(product.name,
                              style: const TextStyle(
                                  fontWeight: FontWeight.w600, fontSize: 14),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis),
                        ),
                        if (product.sku != null)
                          Text('#${product.sku}',
                              style: TextStyle(
                                  color: Colors.grey.shade500, fontSize: 11)),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                        product.productTypeId,
                        style: TextStyle(
                            color: Colors.grey.shade600, fontSize: 12)),
                  ],
                ),
              ),

              const SizedBox(width: 12),

              // Price & stock
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    CurrencyFormatter.format(product.sellingPrice),
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 14),
                  ),
                  const SizedBox(height: 4),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: stockColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.inventory_outlined,
                            color: stockColor, size: 14),
                        const SizedBox(width: 4),
                        Text('${product.quantity}',
                            style: TextStyle(
                                color: stockColor,
                                fontSize: 12,
                                fontWeight: FontWeight.w600)),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final bool isSearching;
  final VoidCallback onRefresh;

  const _EmptyState({required this.isSearching, required this.onRefresh});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.inventory_2_outlined,
                size: 64, color: Colors.grey.shade300),
            const SizedBox(height: 16),
            Text(isSearching ? 'No products found' : 'No products yet',
                style: Theme.of(context)
                    .textTheme
                    .titleMedium
                    ?.copyWith(color: Colors.grey.shade600)),
            const SizedBox(height: 8),
            Text(
                isSearching
                    ? 'Try a different search term'
                    : 'Add your first product to get started',
                style: TextStyle(color: Colors.grey.shade400, fontSize: 14)),
            if (!isSearching) ...[
              const SizedBox(height: 24),
              FilledButton.tonal(
                onPressed: onRefresh,
                child: const Text('Refresh'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}