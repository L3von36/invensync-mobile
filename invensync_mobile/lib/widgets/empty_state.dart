import 'package:flutter/material.dart';
import '../config/theme.dart';

class EmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;

  const EmptyState({
    super.key,
    required this.icon,
    required this.title,
    this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = AppTheme.isDark(context);

    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 56,
            color: (isDark ? AppTheme.textTertiaryDark : AppTheme.mutedText)
                .withValues(alpha: 0.30),
          ),
          const SizedBox(height: 16),
          Text(
            title,
            style: AppTheme.bodyLarge.copyWith(
              fontWeight: FontWeight.w500,
              color: isDark ? AppTheme.textTertiaryDark : AppTheme.mutedText,
            ),
          ),
          if (subtitle != null) ...[
            const SizedBox(height: 4),
            Text(
              subtitle!,
              style: AppTheme.bodySmall.copyWith(
                color: (isDark
                        ? AppTheme.textTertiaryDark
                        : AppTheme.mutedText)
                    .withValues(alpha: 0.70),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ],
      ),
    );
  }
}