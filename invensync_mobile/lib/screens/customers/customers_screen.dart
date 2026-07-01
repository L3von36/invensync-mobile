import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../config/theme.dart';
import '../../providers/data_providers.dart';

class CustomersScreen extends ConsumerStatefulWidget {
  const CustomersScreen({super.key});

  @override
  ConsumerState<CustomersScreen> createState() => _CustomersScreenState();
}

class _CustomersScreenState extends ConsumerState<CustomersScreen> {
  String _searchQuery = '';

  static const _avatarColors = [
    Color(0xFFEA580C), // primary orange
    Color(0xFF2563EB), // blue
    Color(0xFF059669), // green
    Color(0xFF7C3AED), // purple
    Color(0xFFDB2777), // pink
    Color(0xFF0891B2), // cyan
  ];

  Color _getAvatarColor(String name) {
    if (name.isEmpty) return _avatarColors[0];
    int hash = 0;
    for (int i = 0; i < name.length; i++) {
      hash = name.codeUnitAt(i) + ((hash << 5) - hash);
    }
    return _avatarColors[hash.abs() % _avatarColors.length];
  }

  @override
  Widget build(BuildContext context) {
    final textColor = AppTheme.textColor(context);
    final mutedColor = AppTheme.mutedColor(context);
    final cardColor = AppTheme.cardColor(context);
    final borderColor = AppTheme.borderColor(context);
    final padding = AppTheme.pagePadding(context);

    final customersAsync = ref.watch(customersProvider);
    final customers = customersAsync.valueOrNull ?? [];

    final filtered = customers.where((c) {
      if (_searchQuery.isEmpty) return true;
      final q = _searchQuery.toLowerCase();
      return c.name.toLowerCase().contains(q) ||
          (c.phone?.toLowerCase().contains(q) ?? false) ||
          (c.email?.toLowerCase().contains(q) ?? false);
    }).toList();

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
                  Text('Customers', style: AppTheme.heading1.copyWith(color: textColor)),
                  const SizedBox(height: 4),
                  Text('${customers.length} total customers', style: AppTheme.bodySmall.copyWith(color: mutedColor)),
                  const SizedBox(height: 20),

                  // Search
                  TextField(
                    onChanged: (v) => setState(() => _searchQuery = v),
                    style: AppTheme.bodyMedium.copyWith(color: textColor),
                    decoration: InputDecoration(
                      hintText: 'Search by name, phone, or email...',
                      prefixIcon: Icon(Icons.search_rounded, color: mutedColor, size: 20),
                      suffixIcon: _searchQuery.isNotEmpty
                          ? IconButton(
                              icon: Icon(Icons.close, size: 18, color: mutedColor),
                              onPressed: () => setState(() => _searchQuery = ''),
                            )
                          : null,
                      isDense: true,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
                    ),
                  ),
                  const SizedBox(height: 16),
                ]),
              ),
            ),

            if (filtered.isEmpty)
              SliverFillRemaining(
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.people_outline, size: 56, color: mutedColor.withValues(alpha: 0.3)),
                      const SizedBox(height: 16),
                      Text('No customers found', style: AppTheme.bodyLarge.copyWith(color: mutedColor, fontWeight: FontWeight.w500)),
                      const SizedBox(height: 6),
                      Text(_searchQuery.isNotEmpty
                          ? 'Try a different search term'
                          : 'Add your first customer to get started',
                        style: AppTheme.bodySmall.copyWith(color: mutedColor.withValues(alpha: 0.7))),
                    ],
                  ),
                ),
              )
            else
              SliverPadding(
                padding: EdgeInsets.fromLTRB(padding.left, 0, padding.right, 100),
                sliver: SliverList.separated(
                  itemCount: filtered.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 6),
                  itemBuilder: (context, index) {
                    final c = filtered[index];
                    final avatarColor = _getAvatarColor(c.name);
                    return Padding(
                      padding: EdgeInsets.symmetric(horizontal: padding.horizontal / 2),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 10),
                        decoration: BoxDecoration(
                          color: cardColor,
                          borderRadius: BorderRadius.circular(AppTheme.cardRadius),
                          border: Border.all(color: borderColor),
                        ),
                        child: Row(
                          children: [
                            // Avatar
                            Container(
                              width: 44, height: 44,
                              decoration: BoxDecoration(
                                color: avatarColor.withValues(alpha: 0.12),
                                borderRadius: BorderRadius.circular(22),
                              ),
                              child: Center(
                                child: Text(
                                  c.name.isNotEmpty ? c.name[0].toUpperCase() : '?',
                                  style: TextStyle(
                                    fontSize: 17, fontWeight: FontWeight.w700,
                                    color: avatarColor,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 14),
                            // Info
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(c.name, style: AppTheme.bodyLarge.copyWith(color: textColor, fontWeight: FontWeight.w600)),
                                  const SizedBox(height: 3),
                                  Row(
                                    children: [
                                      if (c.phone != null && c.phone!.isNotEmpty) ...[
                                        Icon(Icons.phone_outlined, size: 13, color: mutedColor),
                                        const SizedBox(width: 5),
                                        Text(c.phone!, style: AppTheme.caption.copyWith(color: mutedColor)),
                                      ],
                                      if (c.phone != null && c.phone!.isNotEmpty && c.email != null && c.email!.isNotEmpty)
                                        Padding(
                                          padding: const EdgeInsets.symmetric(horizontal: 8),
                                          child: Text('•', style: AppTheme.caption.copyWith(color: mutedColor.withValues(alpha: 0.4))),
                                        ),
                                      if (c.email != null && c.email!.isNotEmpty)
                                        Flexible(
                                          child: Text(c.email!, style: AppTheme.caption.copyWith(color: mutedColor), overflow: TextOverflow.ellipsis),
                                        ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            Icon(Icons.chevron_right, size: 20, color: mutedColor.withValues(alpha: 0.4)),
                          ],
                        ),
                      ),
                    );
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
        icon: const Icon(Icons.person_add_rounded, size: 20),
        label: const Text('Add Customer', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
        shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(16))),
        elevation: 4,
      ),
    );
  }
}