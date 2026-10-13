import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_ce/hive_ce.dart';

import '../../../core/storage/local_storage.dart';
import '../domain/app_user.dart';
import '../domain/auth_repository.dart';

final authRepositoryProvider = Provider<AuthRepository>(
  (ref) => LocalAuthRepository(ref.watch(sessionBoxProvider)),
);

class LocalAuthRepository implements AuthRepository {
  const LocalAuthRepository(this._box);

  final Box<String> _box;
  static const _emailKey = 'email';

  @override
  AppUser? get currentUser {
    final email = _box.get(_emailKey);
    return email == null ? null : AppUser(email: email);
  }

  @override
  Future<AppUser> signIn({
    required String email,
    required String password,
  }) async {
    await Future<void>.delayed(const Duration(milliseconds: 600));

    final normalizedEmail = email.trim().toLowerCase();
    await writeToStorage(() => _box.put(_emailKey, normalizedEmail));
    return AppUser(email: normalizedEmail);
  }

  @override
  Future<void> signOut() => writeToStorage(() => _box.delete(_emailKey));
}
