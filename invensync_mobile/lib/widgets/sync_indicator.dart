import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../config/theme.dart';
import '../providers/data_providers.dart';
import '../sync/sync_engine.dart';

class SyncIndicator extends ConsumerWidget {
  const SyncIndicator({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final syncStatus = ref.watch(syncStatusProvider);
    final outboxCount = ref.watch(pendingOutboxCountProvider);
    final pending = outboxCount.valueOrNull ?? 0;

    final status = syncStatus.valueOrNull;
    final isSyncing =
        status != null && status != SyncStatus.idle;

    if (!isSyncing && pending == 0) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: isSyncing
            ? AppTheme.primaryColor.withValues(alpha: 0.1)
            : AppTheme.warningColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: 12,
            height: 12,
            child: isSyncing
                ? const CircularProgressIndicator(strokeWidth: 2)
                : Icon(Icons.cloud_upload_outlined,
                    size: 12, color: AppTheme.warningColor),
          ),
          const SizedBox(width: 6),
          Text(
            isSyncing ? 'Syncing...' : '$pending pending',
            style: TextStyle(
              color: isSyncing ? AppTheme.primaryColor : AppTheme.warningColor,
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}