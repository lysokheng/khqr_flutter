import 'dart:convert';
import 'package:crypto/crypto.dart' as crypto;
import 'khqr_models.dart';

/// Production-grade EMVCo Bakong KHQR Generator and CRC-16 Engine.
class KhqrGenerator {
  /// Formats Tag-Length-Value (TLV) string according to EMVCo standard.
  static String formatTlv(String tag, String value) {
    final length = value.length.toString().padLeft(2, '0');
    return '$tag$length$value';
  }

  /// Calculates CRC16-CCITT (polynomial 0x1021, initial value 0xFFFF) checksum.
  /// This adheres strictly to ISO/IEC 13239 and EMVCo Tag 63 specification.
  static String calculateCrc16(String input) {
    final bytes = utf8.encode(input);
    int crc = 0xFFFF;
    const polynomial = 0x1021;

    for (final byte in bytes) {
      for (int i = 0; i < 8; i++) {
        final bit = ((byte >> (7 - i)) & 1) == 1;
        final c15 = ((crc >> 15) & 1) == 1;
        crc = (crc << 1) & 0xFFFF;
        if (c15 ^ bit) {
          crc ^= polynomial;
        }
      }
    }

    return crc.toRadixString(16).toUpperCase().padLeft(4, '0');
  }

  /// Generates a valid dynamic (point-of-initiation "12") EMVCo KHQR payload.
  static KhqrPayloadResult generateDynamicKhqr(KhqrPaymentRequest request) {
    return _buildPayload(request, isDynamic: true);
  }

  /// Generates a valid static (point-of-initiation "11") EMVCo KHQR payload.
  static KhqrPayloadResult generateStaticKhqr(KhqrPaymentRequest request) {
    return _buildPayload(request, isDynamic: false);
  }

  static KhqrPayloadResult _buildPayload(KhqrPaymentRequest request,
      {required bool isDynamic}) {
    final buffer = StringBuffer();

    // Tag 00: Payload Format Indicator (Fixed "01")
    buffer.write(formatTlv('00', '01'));

    // Tag 01: Point of Initiation Method ("12" = Dynamic, "11" = Static)
    buffer.write(formatTlv('01', isDynamic ? '12' : '11'));

    // Tag 29: Merchant Account Information (Bakong TLV sub-scheme)
    final merchantAccountBuffer = StringBuffer();
    merchantAccountBuffer.write(formatTlv('00', request.accountInformation));
    merchantAccountBuffer.write(formatTlv('01', request.merchantId));
    if (request.acquiringBank != null && request.acquiringBank!.isNotEmpty) {
      merchantAccountBuffer.write(formatTlv('02', request.acquiringBank!));
    }
    final merchantAccountPayload = merchantAccountBuffer.toString();
    buffer.write(formatTlv('29', merchantAccountPayload));

    // Tag 52: Merchant Category Code ("0000" default for general retail)
    buffer.write(formatTlv('52', '0000'));

    // Tag 53: Transaction Currency (840 = USD, 116 = KHR)
    buffer.write(formatTlv('53', request.currency.code));

    // Tag 54: Transaction Amount
    if (request.amount > 0 || isDynamic) {
      final formattedAmount = request.currency == KhqrCurrency.khr
          ? request.amount.round().toString()
          : request.amount.toStringAsFixed(2);
      buffer.write(formatTlv('54', formattedAmount));
    }

    // Tag 58: Country Code (Fixed "KH")
    buffer.write(formatTlv('58', 'KH'));

    // Tag 59: Merchant Name (Up to 25 chars)
    final sanitizedMerchantName = request.merchantName.length > 25
        ? request.merchantName.substring(0, 25)
        : request.merchantName;
    buffer.write(formatTlv('59', sanitizedMerchantName));

    // Tag 60: Merchant City (Up to 15 chars)
    final sanitizedCity = request.merchantCity.length > 15
        ? request.merchantCity.substring(0, 15)
        : request.merchantCity;
    buffer.write(formatTlv('60', sanitizedCity));

    // Tag 62: Additional Data Field Template
    final additionalDataBuffer = StringBuffer();
    additionalDataBuffer.write(formatTlv('01', request.billNumber));

    if (request.mobileNumber != null && request.mobileNumber!.isNotEmpty) {
      additionalDataBuffer.write(formatTlv('02', request.mobileNumber!));
    }
    if (request.storeLabel != null && request.storeLabel!.isNotEmpty) {
      additionalDataBuffer.write(formatTlv('03', request.storeLabel!));
    }
    if (request.terminalLabel != null && request.terminalLabel!.isNotEmpty) {
      additionalDataBuffer.write(formatTlv('07', request.terminalLabel!));
    }

    final additionalDataPayload = additionalDataBuffer.toString();
    if (additionalDataPayload.isNotEmpty) {
      buffer.write(formatTlv('62', additionalDataPayload));
    }

    // Tag 63: CRC16 Checksum
    final payloadWithoutCrc = '${buffer.toString()}6304';
    final crcValue = calculateCrc16(payloadWithoutCrc);
    final fullQrString = '$payloadWithoutCrc$crcValue';

    // MD5 generation for idempotency key
    final md5Hash = crypto.md5.convert(utf8.encode(fullQrString)).toString();

    return KhqrPayloadResult(
      qrString: fullQrString,
      md5Hash: md5Hash,
      crc: crcValue,
      createdAt: DateTime.now().toUtc(),
    );
  }
}
