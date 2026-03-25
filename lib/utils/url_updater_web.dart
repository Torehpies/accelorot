// lib/utils/url_updater_web.dart
// ignore_for_file: avoid_web_libraries_in_flutter

import 'package:web/web.dart' as web;

const _sectionToPath = {
  'home': '/',
  'features': '/features',
  'how-it-works': '/how-it-works',
  'impact': '/impact',
  'download': '/downloads',
  'faq': '/faqs',
  'contact': '/contact',
};

const _pathToSection = {
  '/features': 'features',
  '/how-it-works': 'how-it-works',
  '/impact': 'impact',
  '/downloads': 'download',
  '/faqs': 'faq',
  '/contact': 'contact',
};

/// Updates the browser URL hash to reflect the current landing page section
/// without triggering GoRouter navigation.
void updateLandingPageUrl(String section) {
  final path = _sectionToPath[section] ?? '/';
  final newHash = '#$path';
  
  // Use package:web API with JS interop
  if (web.window.location.hash != newHash) {
    web.window.history.replaceState(null, '', newHash);
  }
}

/// Reads the current URL hash to determine the initial section to scroll to.
/// Returns null for the home/root path.
String? getInitialSectionFromUrl() {
  final hash = web.window.location.hash;
  if (hash.isEmpty || hash == '#' || hash == '#/') return null;
  final path = hash.replaceFirst('#', '');
  return _pathToSection[path];
}