import 'package:intl/intl.dart';

/// SecureMail — Date & Time Formatter
/// Usage: DateFormatter.emailTime(dateTime)
class DateFormatter {
  DateFormatter._();

  /// بيعرض الوقت زي Gmail بالظبط:
  /// - نفس اليوم     → 10:30 AM
  /// - نفس السنة     → Mar 15
  /// - سنة تانية    → 12/03/23
  static String emailTime(DateTime dateTime) {
    final now   = DateTime.now();
    final local = dateTime.toLocal();

    final isToday = local.year  == now.year  &&
                    local.month == now.month  &&
                    local.day   == now.day;

    final isThisYear = local.year == now.year;

    if (isToday)    return DateFormat('h:mm a').format(local);
    return DateFormat('d MMM').format(local);
  }

  /// وقت كامل للـ email detail screen
  /// → Mon, Mar 15, 2024 at 10:30 AM
  static String emailFull(DateTime dateTime) {
    final local = dateTime.toLocal();
    return DateFormat("EEE, MMM d, y 'at' h:mm a").format(local);
  }

  /// للإشعارات — "2 hours ago", "just now"
  static String timeAgo(DateTime dateTime) {
    final now      = DateTime.now();
    final local    = dateTime.toLocal();
    final diff     = now.difference(local);

    if (diff.inSeconds < 60)  return 'Just now';
    if (diff.inMinutes < 60)  return '${diff.inMinutes}m ago';
    if (diff.inHours   < 24)  return '${diff.inHours}h ago';
    if (diff.inDays    < 7)   return '${diff.inDays}d ago';
    if (diff.inDays    < 30)  return '${(diff.inDays / 7).floor()}w ago';
    if (diff.inDays    < 365) return '${(diff.inDays / 30).floor()}mo ago';
    return '${(diff.inDays / 365).floor()}y ago';
  }

  /// للـ email detail — "10:30 AM"
  static String timeOnly(DateTime dateTime) =>
      DateFormat('h:mm a').format(dateTime.toLocal());

  /// للـ email detail — "Monday, March 15, 2024"
  static String fullDate(DateTime dateTime) =>
      DateFormat('EEEE, MMMM d, y').format(dateTime.toLocal());
}
