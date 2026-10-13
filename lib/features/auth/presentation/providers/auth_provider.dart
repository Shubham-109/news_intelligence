import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/local_auth_repository.dart';
import '../../domain/app_user.dart';

/// The signed in user, or null when signed out. The session is read from the
/// device at launch, so a returning user goes straight to the feed.
final authControllerProvider = AsyncNotifierProvider<AuthController, AppUser?>(
  AuthController.new,
);

class AuthController extends AsyncNotifier<AppUser?> {
  @override
  AppUser? build() => ref.watch(authRepositoryProvider).currentUser;

  Future<void> signIn({required String email, required String password}) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => ref
          .read(authRepositoryProvider)
          .signIn(email: email, password: password),
    );
  }

  Future<void> signOut() async {
    await ref.read(authRepositoryProvider).signOut();
    state = const AsyncData(null);
  }
}
