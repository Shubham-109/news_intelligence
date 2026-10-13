class AppUser {
  const AppUser({required this.email});

  final String email;

  String get firstName {
    final localPart = email.split('@').first;
    final firstWord = localPart
        .split(RegExp(r'[._+\d-]'))
        .firstWhere((part) => part.isNotEmpty, orElse: () => localPart);
    return firstWord[0].toUpperCase() + firstWord.substring(1).toLowerCase();
  }
}
