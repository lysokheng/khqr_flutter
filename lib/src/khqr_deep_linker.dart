import 'dart:io' show Platform;
import 'khqr_models.dart';

/// Banking Deep-Link Dispatcher for Cambodian Mobile Financial Applications.
class KhqrDeepLinker {
  /// Generates the deep-link URI tailored for specific banking apps.
  /// Automatically inspects runtime platform or accepts manual overrides.
  static String buildDeepLinkUri({
    required CambodianBankApp bank,
    required String qrString,
    bool? overrideIsIOS,
    bool? overrideIsAndroid,
  }) {
    final encodedQr = Uri.encodeComponent(qrString);

    bool isIos = false;
    bool isAndroid = false;

    if (overrideIsIOS != null || overrideIsAndroid != null) {
      isIos = overrideIsIOS ?? false;
      isAndroid = overrideIsAndroid ?? false;
    } else {
      try {
        isIos = Platform.isIOS;
        isAndroid = Platform.isAndroid;
      } catch (_) {
        // Fallback for Web/Wasm environments where Platform throws
        isIos = false;
        isAndroid = false;
      }
    }

    if (isIos) {
      return '${bank.iosScheme}//khqr?qr=$encodedQr';
    } else if (isAndroid) {
      final schemeClean = bank.iosScheme.replaceAll(':', '');
      return 'intent://khqr?qr=$encodedQr#Intent;scheme=$schemeClean;package=${bank.androidPackage};end';
    }

    // Default Universal Link fallback (Web, desktop, or preview)
    return '${bank.universalPrefix}?qr=$encodedQr';
  }

  /// Generates the web / universal link URL.
  static String buildUniversalLink({
    required CambodianBankApp bank,
    required String qrString,
  }) {
    final encodedQr = Uri.encodeComponent(qrString);
    return '${bank.universalPrefix}?qr=$encodedQr';
  }

  /// Returns the complete list of supported banking institutions.
  static List<CambodianBankApp> get supportedBanks => CambodianBankApp.values;
}
