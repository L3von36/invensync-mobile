import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../config/theme.dart';
import 'dashboard/dashboard_screen.dart';
import 'products/products_screen.dart';
import 'sales/sales_screen.dart';
import 'inventory/inventory_screen.dart';
import 'customers/customers_screen.dart';
import '../../providers/data_providers.dart';
import '../../widgets/offline_banner.dart';
import '../../widgets/sync_indicator.dart';

class MainShell extends ConsumerStatefulWidget {
  const MainShell({super.key});

  @override
  ConsumerState<MainShell> createState() => _MainShellState();
}

class _MainShellState extends ConsumerState<MainShell> {
  int _currentIndex = 0;

  static const _screens = <Widget>[
    DashboardScreen(),
    ProductsScreen(),
    SalesScreen(),
    InventoryScreen(),
    CustomersScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final isDark = AppTheme.isDark(context);
    final authState = ref.watch(authStateProvider);
    final org = authState.valueOrNull?.organization;
    final user = authState.valueOrNull?.user;
    final isOnlineAsync = ref.watch(isOnlineProvider);
    final isOnline = isOnlineAsync.valueOrNull ?? true;
    final pendingAsync = ref.watch(pendingOutboxCountProvider);
    final pendingCount = pendingAsync.valueOrNull ?? 0;

    final userName = user?.name ?? '';
    final initialLetter =
        userName.isNotEmpty ? userName[0].toUpperCase() : '?';
    final orgName = org?.name ?? '';

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        scrolledUnderElevation: 0.5,
        backgroundColor: isDark ? AppTheme.cardDark : AppTheme.cardLight,
        surfaceTintColor: Colors.transparent,
        shape: Border(
          bottom: BorderSide(
            color: isDark ? AppTheme.borderDark : AppTheme.borderLight,
            width: 1,
          ),
        ),
        title: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: AppTheme.primaryColor,
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(
                Icons.inventory_2_outlined,
                size: 18,
                color: Colors.white,
              ),
            ),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'InvenSync',
                  style: AppTheme.heading3,
                ),
                if (orgName.isNotEmpty)
                  Text(
                    orgName,
                    style: AppTheme.overline.copyWith(
                      color: isDark
                          ? AppTheme.textTertiaryDark
                          : AppTheme.mutedText,
                    ),
                  ),
              ],
            ),
          ],
        ),
        actions: [
          if (!isOnline) const OfflineBanner(),
          if (pendingCount > 0) SyncIndicator(pendingCount: pendingCount),
          const SizedBox(width: 4),
          GestureDetector(
            onTap: () {},
            child: Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: AppTheme.primaryColor.withValues(alpha: 0.10),
                shape: BoxShape.circle,
              ),
              alignment: Alignment.center,
              child: Text(
                initialLetter,
                style: AppTheme.bodyLarge.copyWith(
                  color: AppTheme.primaryColor,
                  fontWeight: FontWeight.w700,
                  letterSpacing: -0.2,
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: IndexedStack(index: _currentIndex, children: _screens),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: isDark ? AppTheme.cardDark : AppTheme.cardLight,
          border: Border(
            top: BorderSide(
              color: isDark ? AppTheme.borderDark : AppTheme.borderLight,
              width: 1,
            ),
          ),
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (index) => setState(() => _currentIndex = index),
          type: BottomNavigationBarType.fixed,
          elevation: 0,
          backgroundColor: Colors.transparent,
          selectedLabelStyle: const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w600,
          ),
          unselectedLabelStyle: const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w500,
          ),
          selectedItemColor: AppTheme.primaryColor,
          unselectedItemColor:
              isDark ? AppTheme.textTertiaryDark : AppTheme.textTertiary,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.dashboard_outlined),
              activeIcon: Icon(Icons.dashboard),
              label: 'Dashboard',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.inventory_2_outlined),
              activeIcon: Icon(Icons.inventory_2),
              label: 'Products',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.receipt_long_outlined),
              activeIcon: Icon(Icons.receipt_long),
              label: 'Sales',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.warehouse_outlined),
              activeIcon: Icon(Icons.warehouse),
              label: 'Inventory',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.people_outline),
              activeIcon: Icon(Icons.people),
              label: 'Customers',
            ),
          ],
        ),
      ),
    );
  }
}