import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

extension ProviderCache on Ref {
  /// Keeps an auto disposed provider alive for [duration] after its last
  /// listener goes away, so coming back to it soon after reuses its state.
  void cacheFor(Duration duration) {
    final link = keepAlive();
    Timer? timer;
    onCancel(() => timer = Timer(duration, link.close));
    onResume(() => timer?.cancel());
    onDispose(() => timer?.cancel());
  }
}
