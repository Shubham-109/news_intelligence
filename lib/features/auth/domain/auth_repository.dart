import 'app_user.dart';

abstract interface class AuthRepository {
  AppUser? get currentUser;

  Future<AppUser> signIn({required String email, required String password});

  Future<void> signOut();
}
