import 'package:khqr_flutter/khqr_flutter.dart';

void main() {
  print('===================================================');
  print('  khqr_flutter — Bakong EMVCo Dynamic KHQR Example ');
  print('===================================================\n');

  // 1. Create a Dynamic Payment Request
  const request = KhqrPaymentRequest(
    accountInformation: '500050937@abaa',
    merchantId: 'DIGITAL_KEY_STORE',
    merchantName: 'Digital Key Store',
    merchantCity: 'Phnom Penh',
    amount: 249.00,
    currency: KhqrCurrency.usd,
    billNumber: 'INV-2026-DEMO',
    storeLabel: 'Web Store',
    terminalLabel: 'API-01',
  );

  // 2. Generate Dynamic KHQR Payload
  final result = KhqrGenerator.generateDynamicKhqr(request);

  print('Generated Dynamic KHQR Payload:');
  print(result.qrString);
  print('\nPayload Checksum (CRC16): ${result.crc}');
  print('Idempotency Hash (MD5): ${result.md5Hash}');

  // 3. Reverse Parse & Verify
  print('\n--- Reverse Parsing & CRC Integrity Verification ---');
  final parsed = KhqrParser.parse(result.qrString);
  print('Is Valid EMVCo: ${parsed.isValid}');
  print('Is CRC Valid:   ${parsed.isCrcValid}');
  print('Merchant Name:  ${parsed.merchantName}');
  print('Amount & Curr:  ${parsed.amount} ${parsed.currency?.symbol}');
  print('Account Info:   ${parsed.accountInformation}');

  // 4. Generate Mobile Banking Deep-Links
  print('\n--- Banking Deep-Links ---');
  for (final bank in KhqrDeepLinker.supportedBanks) {
    final iosUri = KhqrDeepLinker.buildDeepLinkUri(
      bank: bank,
      qrString: result.qrString,
      overrideIsIOS: true,
    );
    final universal = KhqrDeepLinker.buildUniversalLink(
      bank: bank,
      qrString: result.qrString,
    );
    print('${bank.name}:');
    print('  iOS Scheme: $iosUri');
    print('  Universal:  $universal');
  }
}
