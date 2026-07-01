import 'package:flutter/material.dart';
import '../config/theme.dart';

class OfflineBanner extends StatelessWidget {
  const OfflineBanner({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = AppTheme.isDark(context);

    return Container(
      margin: const EdgeInsets.only(right: 4),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
      decoration: BoxDecoration(
        color: isDark
            ? AppTheme.warningColor.withValues(alpha: 0.15)
            : AppTheme.warningBg,
        borderRadius: BorderRadius.circular(20),
        border: isDark
            ? null
            : Border.all(
                color: AppTheme.warningColor.withValues(alpha: 0.30),
                width: 1,
              ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.wifi_off_rounded,
            size: 14,
            color: isDark ? AppTheme.warningColor : AppTheme.warningText,
          ),
          const SizedBox(width: 6),
          Text(
            'Offline',
            style: AppTheme.caption.copyWith(
              color: isDark ? AppTheme.warningColor : AppTheme.warningText,
            ),
          ),
        ],
      ),
    );
  }
}