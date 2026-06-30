import 'package:intl/intl.dart';

class DateFormatter {
  static String format(String? dateStr) {
    if (dateStr == null || dateStr.isEmpty) return '-';
    try {
      final date = DateTime.parse(dateStr);
      return DateFormat('MMM d, yyyy').format(date);
    } catch (_) {
      return dateStr;
    }
  }

  static String formatDateTime(String? dateStr) {
    if (dateStr == null || dateStr.isEmpty) return '-';
    try {
      final date = DateTime.parse(dateStr);
      return DateFormat('MMM d, yyyy HH:mm').format(date);
    } catch (_) {
      return dateStr;
    }
  }

  static String formatTime(String? dateStr) {
    if (dateStr == null || dateStr.isEmpty) return '-';
    try {
      final date = DateTime.parse(dateStr);
      return DateFormat('HH:mm').format(date);
    } catch (_) {
      return dateStr;
    }
  }

  static String relative(String? dateStr) {
    if (dateStr == null || dateStr.isEmpty) return '-';
    try {
      final date = DateTime.parse(dateStr);
      final now = DateTime.now();
      final diff = now.difference(date);

      if (diff.inSeconds < 60) return 'Just now';
      if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
      if (diff.inHours < 24) return '${diff.inHours}h ago';
      if (diff.inDays < 7) return '${diff.inDays}d ago';
      return format(dateStr);
    } catch (_) {
      return dateStr;
    }
  }
}