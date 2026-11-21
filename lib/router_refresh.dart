import 'dart:async';
import 'package:flutter/foundation.dart';

class RouterRefresh extends ChangeNotifier {
  RouterRefresh(Stream<Object?> stream) {
    _suscripcion = stream.listen((_) => notifyListeners());
  }

  late final StreamSubscription<Object?> _suscripcion;

  @override
  void dispose() {
    _suscripcion.cancel();
    super.dispose();
  }
}
