import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter_application_1/routes/auth_status.dart';

class GoRouterRefreshStream extends ChangeNotifier {
	late final StreamSubscription<AuthStatusState> _subscription;

	GoRouterRefreshStream(Stream<AuthStatusState> stream) {
		_subscription = stream.listen((_) => notifyListeners());
	}

	@override
	void dispose() {
		_subscription.cancel();
		super.dispose();
	}
}
