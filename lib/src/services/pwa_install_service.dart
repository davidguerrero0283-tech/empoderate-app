import 'package:flutter/foundation.dart';
import 'package:js/js.dart';
// ignore: avoid_web_libraries_in_flutter
import 'dart:js_util' as js_util;
// ignore: avoid_web_libraries_in_flutter
import 'dart:html' as html;

class PwaInstallService {
  static final PwaInstallService _instance = PwaInstallService._internal();
  factory PwaInstallService() => _instance;
  PwaInstallService._internal();

  final ValueNotifier<bool> canInstall = ValueNotifier(false);
  bool _isIOS = false;

  bool get isIOS => _isIOS;

  void init() {
    if (!kIsWeb) return;

    // Detect iOS
    final userAgent = html.window.navigator.userAgent.toLowerCase();
    _isIOS = userAgent.contains('iphone') || userAgent.contains('ipad') || userAgent.contains('ipod');

    if (_isIOS) {
       // Check if already installed (standalone mode)
       // navigator.standalone is non-standard but works on iOS Safari
       final isStandalone = js_util.getProperty(html.window.navigator, 'standalone') == true;
       if (!isStandalone) {
         canInstall.value = true;
       }
    } else {
      // Android / Desktop: Check for deferredPrompt from index.html
      // We poll briefly because proper JS event might have fired before Dart init
      _checkDeferredPrompt();
      // Also listen purely in case it fires late (rare but possible)
      html.window.on['beforeinstallprompt'].listen((event) {
        // Event verified in index.html logic, but here we just know it happened.
        // index.html logic sets window.deferredPrompt
        _checkDeferredPrompt();
      });
    }
  }

  void _checkDeferredPrompt() {
    try {
      final prompt = js_util.getProperty(html.window, 'deferredPrompt');
      if (prompt != null) {
        canInstall.value = true;
      } else {
        // Check periodically for a few seconds if not found yet? 
        // usually it is instant if the criteria are met.
      }
    } catch (e) {
      debugPrint('Error checking deferredPrompt: $e');
    }
  }

  void promptInstall() {
    if (_isIOS) {
       // iOS cannot programmatically prompt. The UI should show the instructions modal.
       // This method shouldn't really be called for iOS except to trigger logic flow if unified.
       return;
    }

    try {
      // Call the function defined in index.html
      js_util.callMethod(html.window, 'showInstallPrompt', []);
      // Optimistically hide the button, or we can listen to the choice result if we wanted deep integration
      canInstall.value = false; 
    } catch (e) {
      debugPrint('Error triggering install prompt: $e');
    }
  }
}
