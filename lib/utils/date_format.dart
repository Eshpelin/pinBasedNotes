import 'package:intl/intl.dart';

class DateFormatter {
  /// Format a timestamp for display in the notes list
  ///
  /// Shows relative time for recent notes (e.g., "5 minutes ago")
  /// Shows absolute time for older notes (e.g., "Jan 15, 2:30 PM")
  static String formatTimestamp(int millisecondsSinceEpoch) {
    final dateTime = DateTime.fromMillisecondsSinceEpoch(millisecondsSinceEpoch);
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    // Less than 1 minute
    if (difference.inSeconds < 60) {
      return 'Just now';
    }

    // Less than 1 hour
    if (difference.inMinutes < 60) {
      final minutes = difference.inMinutes;
      return '$minutes ${minutes == 1 ? 'minute' : 'minutes'} ago';
    }

    // Less than 24 hours
    if (difference.inHours < 24) {
      final hours = difference.inHours;
      return '$hours ${hours == 1 ? 'hour' : 'hours'} ago';
    }

    // Less than 7 days
    if (difference.inDays < 7) {
      final days = difference.inDays;
      return '$days ${days == 1 ? 'day' : 'days'} ago';
    }

    // Same year - show month, day, and time
    if (dateTime.year == now.year) {
      return DateFormat('MMM d, h:mm a').format(dateTime);
    }

    // Different year - show full date
    return DateFormat('MMM d, yyyy').format(dateTime);
  }

  /// Format a timestamp as a full date and time
  static String formatFullDateTime(int millisecondsSinceEpoch) {
    final dateTime = DateTime.fromMillisecondsSinceEpoch(millisecondsSinceEpoch);
    return DateFormat('MMM d, yyyy h:mm a').format(dateTime);
  }

  /// Format a timestamp as just the date
  static String formatDate(int millisecondsSinceEpoch) {
    final dateTime = DateTime.fromMillisecondsSinceEpoch(millisecondsSinceEpoch);
    return DateFormat('MMM d, yyyy').format(dateTime);
  }

  /// Format a timestamp as just the time
  static String formatTime(int millisecondsSinceEpoch) {
    final dateTime = DateTime.fromMillisecondsSinceEpoch(millisecondsSinceEpoch);
    return DateFormat('h:mm a').format(dateTime);
  }
}
