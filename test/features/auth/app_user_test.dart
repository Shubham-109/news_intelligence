import 'package:flutter_test/flutter_test.dart';
import 'package:news_intelligence/features/auth/domain/app_user.dart';

void main() {
  test('firstName takes the first word of the email', () {
    String firstName(String email) => AppUser(email: email).firstName;

    expect(firstName('priya.shah@example.com'), 'Priya');
    expect(firstName('JOHN_smith@example.com'), 'John');
    expect(firstName('ana@example.com'), 'Ana');
    expect(firstName('42@example.com'), '42');
  });
}
