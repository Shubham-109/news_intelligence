import 'app_user.dart';

/// Signs people in and out and remembers who is signed in.
abstract interface class AuthRepository {
  /// The user from the last session, or null when nobody is signed in.
  AppUser? get currentUser;

  Future<AppUser> signIn({required String email, required String password});

  Future<void> signOut();
}
