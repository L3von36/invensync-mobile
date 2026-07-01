import 'package:flutter/material.dart';
import '../config/theme.dart';

class SyncIndicator extends StatelessWidget {
  final int pendingCount;

  const SyncIndicator({super.key, required this.pendingCount});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(right: 4),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
      decoration: BoxDecoration(
        color: AppTheme.primaryColor.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppTheme.primaryColor.withValues(alpha: 0.25),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.cloud_sync_outlined,
            size: 14,
            color: AppTheme.primaryColor,
          ),
          const SizedBox(width: 6),
          Text(
            '$pendingCount pending',
            style: AppTheme.caption.copyWith(
              color: AppTheme.primaryColor,
            ),
          ),
        ],
      ),
    );
  }
}