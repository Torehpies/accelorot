/// Conditional export: uses web implementation on web, stub on other platforms.
library;

export 'url_updater_stub.dart'
    if (dart.library.js_interop) 'url_updater_web.dart';