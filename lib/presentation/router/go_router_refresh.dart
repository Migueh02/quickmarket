import 'dart:async';

import 'package:flutter/foundation.dart';

/// Integra un `Stream` de Firebase Auth con GoRouter (`refreshListenable`).
class GoRouterRefreshStream extends ChangeNotifier {
  GoRouterRefreshStream(Stream<dynamic> stream) {
    _subscription = stream.listen((_) => notifyListeners());
  }

  late final StreamSubscription<dynamic> _subscription;

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}
