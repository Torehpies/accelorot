import 'package:flutter_riverpod/flutter_riverpod.dart';

class SelectedBatchNotifier extends Notifier<String?> {
  @override
  String? build() {
    // ✅ Prevent disposal on navigation
    ref.keepAlive();
    return null;
  }

  void setBatch(String? batchId) {
    state = batchId;
  }

  void clearSelection() {
    state = null;
  }
}

///  Keep alive provider to persist selected batch across navigation
final selectedBatchIdProvider =
    NotifierProvider<SelectedBatchNotifier, String?>(
      () => SelectedBatchNotifier(),
      //  Prevent auto-disposal
      dependencies: const [],
    );
