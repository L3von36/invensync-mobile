import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/data_providers.dart';

class OfflineBanner extends ConsumerWidget {
  final Widget child;
  const OfflineBanner({super.key, required this.child});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isOnline = ref.watch(isOnlineProvider);

    return Column(
      children: [
        if (isOnline.valueOrNull == false)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            color: const Color(0xFF6B7280),
            child: const Row(
              children: [
                Icon(Icons.wifi_off, color: Colors.white, size: 16),
                SizedBox(width: 8),
                Text('You are offline. Changes will sync when reconnected.',
                    style: TextStyle(color: Colors.white, fontSize: 13)),
              ],
            ),
          ),
        Expanded(child: child),
      ],
    );
  }
}