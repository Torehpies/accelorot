// lib/ui/core/toast/mobile_toast_service.dart

import 'package:flutter/material.dart';
import 'mobile_toast.dart';
import 'toast_type.dart';

/// Service to show mobile toasts using OverlayEntries.
class MobileToastService {
  static final List<OverlayEntry> _activeToasts = [];

  static const double _topSafeOffset = 56.0;  // below status bar + a bit
  static const double _toastHeight = 56.0;    // approximate rendered height
  static const double _toastSpacing = 10.0;

  static void show(
    BuildContext context, {
    required String message,
    ToastType type = ToastType.success,
    Duration duration = const Duration(seconds: 2, milliseconds: 500),
  }) {
    final overlay = Overlay.of(context);
    late OverlayEntry entry;

    // Snapshot the current index so position is fixed at insertion time
    final index = _activeToasts.length;
    final topPosition = _topSafeOffset + index * (_toastHeight + _toastSpacing);

    entry = OverlayEntry(
      builder: (context) => Positioned(
        top: topPosition,
        left: 0,
        right: 0,
        child: Align(
          alignment: Alignment.topCenter,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: MobileToast(
              message: message,
              type: type,
              onDismissed: () => _remove(entry),
            ),
          ),
        ),
      ),
    );

    _activeToasts.add(entry);
    overlay.insert(entry);

    // Auto-dismiss
    Future.delayed(duration, () {
      if (_activeToasts.contains(entry)) {
        _remove(entry);
      }
    });
  }

  static void _remove(OverlayEntry entry) {
    if (!_activeToasts.contains(entry)) return;
    entry.remove();
    _activeToasts.remove(entry);
    for (final e in _activeToasts) {
      e.markNeedsBuild();
    }
  }

  static void clearAll() {
    for (final entry in List.from(_activeToasts)) {
      entry.remove();
    }
    _activeToasts.clear();
  }
}