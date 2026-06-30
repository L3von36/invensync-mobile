import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../utils/currency_formatter.dart';

class ProductCard extends StatelessWidget {
  final String name;
  final double price;
  final double stock;
  final String? imageUrl;
  final String? sku;
  final bool lowStock;
  final VoidCallback? onTap;

  const ProductCard({
    super.key,
    required this.name,
    required this.price,
    required this.stock,
    this.imageUrl,
    this.sku,
    this.lowStock = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              // Product image or placeholder
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: SizedBox(
                  width: 56,
                  height: 56,
                  child: imageUrl != null && imageUrl!.isNotEmpty
                      ? CachedNetworkImage(
                          imageUrl: imageUrl!,
                          fit: BoxFit.cover,
                          placeholder: (_, __) => Container(
                            color: theme.colorScheme.surfaceContainerHighest,
                            child: Icon(
                              Icons.inventory_2_outlined,
                              color: theme.colorScheme.outline,
                            ),
                          ),
                          errorWidget: (_, __, ___) => Container(
                            color: theme.colorScheme.surfaceContainerHighest,
                            child: Icon(
                              Icons.broken_image_outlined,
                              color: theme.colorScheme.outline,
                            ),
                          ),
                        )
                      : Container(
                          color: theme.colorScheme.surfaceContainerHighest,
                          child: Icon(
                            Icons.inventory_2_outlined,
                            color: theme.colorScheme.outline,
                          ),
                        ),
                ),
              ),
              const SizedBox(width: 12),
              // Product details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (sku != null && sku!.isNotEmpty) ...[
                      const SizedBox(height: 2),
                      Text(
                        sku!,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.outline,
                        ),
                      ),
                    ],
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Text(
                          CurrencyFormatter.format(price),
                          style: theme.textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: theme.colorScheme.primary,
                          ),
                        ),
                        const Spacer(),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: lowStock
                                ? Colors.red.shade50
                                : Colors.green.shade50,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            '${stock.toInt()} in stock',
                            style: theme.textTheme.labelSmall?.copyWith(
                              color: lowStock ? Colors.red.shade700 : Colors.green.shade700,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}