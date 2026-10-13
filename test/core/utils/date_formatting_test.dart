import 'package:flutter_test/flutter_test.dart';
import 'package:news_intelligence/core/utils/date_formatting.dart';

void main() {
  test('formatRelativeTime shortens recent times and dates older ones', () {
    final now = DateTime(2026, 10, 13, 12);

    String format(DateTime time) => formatRelativeTime(time, now: now);

    expect(format(now.subtract(const Duration(seconds: 20))), 'Just now');
    expect(format(now.subtract(const Duration(minutes: 5))), '5m ago');
    expect(format(now.subtract(const Duration(hours: 3))), '3h ago');
    expect(format(now.subtract(const Duration(days: 2))), '2d ago');
    expect(format(DateTime(2026, 9, 1)), '1 Sep');
    expect(format(DateTime(2024, 9, 1)), '1 Sep 2024');
  });
}
