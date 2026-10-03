import 'khqr_generator.dart';
import 'khqr_models.dart';

/// EMVCo Tag-Length-Value (TLV) Reverse Parser for Bakong KHQR strings.
class KhqrParser {
  /// Parses an EMVCo QR string into a structured [KhqrParsedData] instance.
  /// Validates string format, extracts sub-tags, and verifies CRC-16 checksum integrity.
  static KhqrParsedData parse(String qrString) {
    if (qrString.isEmpty || qrString.length < 10) {
      return const KhqrParsedData(isValid: false, isCrcValid: false);
    }

    final rawTags = <String, String>{};
    int index = 0;

    try {
      while (index < qrString.length) {
        if (index + 4 > qrString.length) break;

        final tag = qrString.substring(index, index + 2);
        final length =
            int.tryParse(qrString.substring(index + 2, index + 4)) ?? 0;
        index += 4;

        if (index + length > qrString.length) break;
        final value = qrString.substring(index, index + length);
        rawTags[tag] = value;
        index += length;
      }
    } catch (_) {
      return const KhqrParsedData(isValid: false, isCrcValid: false);
    }

    // Verify CRC (Tag 63)
    final reportedCrc = rawTags['63'];
    bool isCrcValid = false;

    if (reportedCrc != null && qrString.contains('6304')) {
      final crcIndex = qrString.lastIndexOf('6304');
      final payloadWithoutCrc = qrString.substring(0, crcIndex + 4);
      final calculatedCrc = KhqrGenerator.calculateCrc16(payloadWithoutCrc);
      isCrcValid = calculatedCrc.toUpperCase() == reportedCrc.toUpperCase();
    }

    // Extract Tag 29 (Merchant Account Info Sub-tags)
    String? accountInfo;
    String? merchantId;
    if (rawTags.containsKey('29')) {
      final tag29Value = rawTags['29']!;
      final subTags = _parseSubTags(tag29Value);
      accountInfo = subTags['00'];
      merchantId = subTags['01'];
    }

    // Extract Tag 62 (Additional Data Sub-tags)
    String? billNumber;
    String? storeLabel;
    String? terminalLabel;
    if (rawTags.containsKey('62')) {
      final tag62Value = rawTags['62']!;
      final subTags = _parseSubTags(tag62Value);
      billNumber = subTags['01'];
      storeLabel = subTags['03'];
      terminalLabel = subTags['07'];
    }

    // Extract Currency & Amount
    KhqrCurrency? currency;
    if (rawTags.containsKey('53')) {
      currency = KhqrCurrency.fromCode(rawTags['53']!);
    }

    double? amount;
    if (rawTags.containsKey('54')) {
      amount = double.tryParse(rawTags['54']!);
    }

    final merchantName = rawTags['59'];
    final merchantCity = rawTags['60'];

    return KhqrParsedData(
      isValid: rawTags.containsKey('00') &&
          rawTags.containsKey('29') &&
          rawTags.containsKey('63'),
      isCrcValid: isCrcValid,
      crc: reportedCrc,
      merchantName: merchantName,
      merchantCity: merchantCity,
      accountInformation: accountInfo,
      merchantId: merchantId,
      amount: amount,
      currency: currency,
      billNumber: billNumber,
      storeLabel: storeLabel,
      terminalLabel: terminalLabel,
      rawTags: rawTags,
    );
  }

  static Map<String, String> _parseSubTags(String content) {
    final map = <String, String>{};
    int idx = 0;
    while (idx < content.length) {
      if (idx + 4 > content.length) break;
      final tag = content.substring(idx, idx + 2);
      final len = int.tryParse(content.substring(idx + 2, idx + 4)) ?? 0;
      idx += 4;
      if (idx + len > content.length) break;
      map[tag] = content.substring(idx, idx + len);
      idx += len;
    }
    return map;
  }
}
