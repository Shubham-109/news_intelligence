import 'package:intl/intl.dart';

/// Compact age of a story for lists: "Just now", "5m ago", "3h ago", "2d ago",
/// then a short date such as "12 Oct", with the year when it differs.
String formatRelativeTime(DateTime time, {DateTime? now}) {
  final reference = now ?? DateTime.now();
  final age = reference.difference(time);

  if (age.inMinutes < 1) return 'Just now';
  if (age.inHours < 1) return '${age.inMinutes}m ago';
  if (age.inDays < 1) return '${age.inHours}h ago';
  if (age.inDays < 7) return '${age.inDays}d ago';

  final local = time.toLocal();
  final pattern = local.year == reference.year ? 'd MMM' : 'd MMM y';
  return DateFormat(pattern).format(local);
}

/// Full publication date for the article page, such as "13 October 2026, 09:30".
String formatFullDate(DateTime time) {
  return DateFormat('d MMMM y, HH:mm').format(time.toLocal());
}
