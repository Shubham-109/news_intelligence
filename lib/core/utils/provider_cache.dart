import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

extension ProviderCache on Ref {
  void cacheFor(Duration duration) {
    final link = keepAlive();
    Timer? timer;
    onCancel(() => timer = Timer(duration, link.close));
    onResume(() => timer?.cancel());
    onDispose(() => timer?.cancel());
  }
}
