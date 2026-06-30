import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:drift/drift.dart' hide Column;
import '../../config/theme.dart';
import '../../db/database.dart' hide User;
import '../../providers/data_providers.dart';

extension CustomerHelpers on Customer {
  int get salesCount => 0;
}

class CustomersScreen extends ConsumerStatefulWidget {
  const CustomersScreen({super.key});

  @override
  ConsumerState<CustomersScreen> createState() => _CustomersScreenState();
}

class _CustomersScreenState extends ConsumerState<CustomersScreen> {
  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    final customersAsync = ref.watch(customersProvider);
    final allCustomers = customersAsync.valueOrNull ?? [];

    final filtered = allCustomers.where((c) {
      return _searchQuery.isEmpty ||
          c.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          (c.phone?.toLowerCase().contains(_searchQuery.toLowerCase()) ?? false) ||
          (c.email?.toLowerCase().contains(_searchQuery.toLowerCase()) ?? false);
    }).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Customers'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              onChanged: (v) => setState(() => _searchQuery = v),
              decoration: InputDecoration(
                hintText: 'Search customers...',
                prefixIcon: const Icon(Icons.search),
              ),
            ),
          ),
          Expanded(
            child: filtered.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.group_outlined,
                            size: 64, color: Colors.grey.shade300),
                        const SizedBox(height: 16),
                        Text('No customers yet',
                            style: TextStyle(color: Colors.grey.shade600)),
                      ],
                    ),
                  )
                : RefreshIndicator(
                    onRefresh: () => ref.refresh(customersProvider.future),
                    child: ListView.builder(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 100),
                      itemCount: filtered.length,
                      itemBuilder: (context, index) =>
                          _CustomerCard(customer: filtered[index]),
                    ),
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {},
        icon: const Icon(Icons.person_add),
        label: const Text('Add Customer'),
      ),
    );
  }
}

class _CustomerCard extends StatelessWidget {
  final Customer customer;
  const _CustomerCard({required this.customer});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        contentPadding: const EdgeInsets.all(12),
        leading: CircleAvatar(
          backgroundColor: AppTheme.primaryColor.withValues(alpha: 0.1),
          child: Text(customer.name.isNotEmpty ? customer.name[0].toUpperCase() : '?',
              style: TextStyle(
                  color: AppTheme.primaryColor,
                  fontWeight: FontWeight.bold,
                  fontSize: 18)),
        ),
        title: Text(customer.name,
            style: const TextStyle(fontWeight: FontWeight.w600)),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (customer.phone != null)
              Row(
                children: [
                  Icon(Icons.phone, size: 13, color: Colors.grey.shade500),
                  const SizedBox(width: 4),
                  Text(customer.phone!,
                      style: TextStyle(
                          color: Colors.grey.shade600, fontSize: 13)),
                ],
              ),
            if (customer.salesCount != null && customer.salesCount! > 0)
              Text('${customer.salesCount} purchases',
                  style: TextStyle(
                      color: Colors.grey.shade400, fontSize: 12)),
          ],
        ),
        trailing: const Icon(Icons.chevron_right, color: Colors.grey),
        onTap: () {},
      ),
    );
  }
}