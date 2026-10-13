import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_ce/hive_ce.dart';
import 'package:path_provider/path_provider.dart';

import '../error/failure.dart';

abstract final class HiveBoxes {
  static const session = 'session';
  static const favorites = 'favorites';
}

Future<void> initLocalStorage() async {
  final directory = await getApplicationSupportDirectory();
  Hive.init(directory.path);
  await Future.wait([
    Hive.openBox<String>(HiveBoxes.session),
    Hive.openBox<Map>(HiveBoxes.favorites),
  ]);
}

final sessionBoxProvider = Provider<Box<String>>(
  (ref) => Hive.box<String>(HiveBoxes.session),
);

final favoritesBoxProvider = Provider<Box<Map>>(
  (ref) => Hive.box<Map>(HiveBoxes.favorites),
);

Future<void> writeToStorage(Future<void> Function() write) async {
  try {
    await write();
  } on HiveError {
    throw const StorageFailure();
  } on FileSystemException {
    throw const StorageFailure();
  }
}
