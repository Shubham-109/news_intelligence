/// The person using the app.
class AppUser {
  const AppUser({required this.email});

  final String email;

  /// First name taken from the email for the greeting, such as "Priya" for
  /// priya.shah@example.com.
  String get firstName {
    final localPart = email.split('@').first;
    final firstWord = localPart
        .split(RegExp(r'[._+\d-]'))
        .firstWhere((part) => part.isNotEmpty, orElse: () => localPart);
    return firstWord[0].toUpperCase() + firstWord.substring(1).toLowerCase();
  }
}
