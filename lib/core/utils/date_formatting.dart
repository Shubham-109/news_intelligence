import 'package:intl/intl.dart';

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

String formatFullDate(DateTime time) {
  return DateFormat('d MMMM y, HH:mm').format(time.toLocal());
}
