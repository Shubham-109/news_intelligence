import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_ce/hive_ce.dart';
import 'package:path_provider/path_provider.dart';

/// Names of the Hive boxes the app keeps on the device.
abstract final class HiveBoxes {
  static const favorites = 'favorites';
}

/// Opens local storage before the first frame, so repositories can read
/// their boxes synchronously.
Future<void> initLocalStorage() async {
  final directory = await getApplicationSupportDirectory();
  Hive.init(directory.path);
  await Hive.openBox<Map>(HiveBoxes.favorites);
}

final favoritesBoxProvider = Provider<Box<Map>>(
  (ref) => Hive.box<Map>(HiveBoxes.favorites),
);
