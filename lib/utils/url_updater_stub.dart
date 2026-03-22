// lib/utils/url_updater_stub.dart

/// Stub implementation for non-web platforms.
/// URL hash navigation is only relevant for web.

void updateLandingPageUrl(String section) {
  // No-op on mobile/desktop
}

String? getInitialSectionFromUrl() {
  // No hash-based navigation on non-web
  return null;
}