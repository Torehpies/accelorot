// lib/ui/core/services/toast_service.dart

import 'package:flutter/material.dart';
import 'custom_toast.dart';

/// Service to manage toast notifications
class ToastService {
  static final List<OverlayEntry> _activeToasts = [];
  static const double _topOffset = 20.0;
  static const double _rightOffset = 20.0;
  static const double _toastSpacing = 12.0;

  /// Show a toast notification
  static void show(
    BuildContext context, {
    required String message,
    Duration duration = const Duration(seconds: 2),
  }) {
    final overlay = Overlay.of(context);
    late OverlayEntry overlayEntry;

    // Calculate position based on existing toasts
    final toastIndex = _activeToasts.length;
    final topPosition =
        _topOffset + (toastIndex * (_toastSpacing + 60)); // 60 = toast height

    overlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        top: topPosition,
        right: _rightOffset,
        child: CustomToast(
          message: message,
          onDismissed: () {
            overlayEntry.remove();
            _activeToasts.remove(overlayEntry);
            _repositionToasts();
          },
        ),
      ),
    );

    _activeToasts.add(overlayEntry);
    overlay.insert(overlayEntry);

    // Auto-dismiss after duration
    Future.delayed(duration, () {
      if (_activeToasts.contains(overlayEntry)) {
        overlayEntry.remove();
        _activeToasts.remove(overlayEntry);
        _repositionToasts();
      }
    });
  }

  /// Reposition remaining toasts after one is removed
  static void _repositionToasts() {
    for (int i = 0; i < _activeToasts.length; i++) {
      _activeToasts[i].markNeedsBuild();
    }
  }

  /// Clear all active toasts
  static void clearAll() {
    for (final toast in _activeToasts) {
      toast.remove();
    }
    _activeToasts.clear();
  }
}
