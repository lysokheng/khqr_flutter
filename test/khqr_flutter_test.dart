import 'package:test/test.dart';
import 'package:khqr_flutter/khqr_flutter.dart';

void main() {
  group('CRC-16 CCITT Calculation', () {
    test('Calculates standard CCITT CRC-16 for ASCII "123456789"', () {
      final crc = KhqrGenerator.calculateCrc16('123456789');
      expect(crc, equals('29B1'));
    });

    test('CRC output is always 4-character uppercase hexadecimal', () {
      final crc = KhqrGenerator.calculateCrc16('0002010102126304');
      expect(crc.length, equals(4));
      expect(RegExp(r'^[0-9A-F]{4}$').hasMatch(crc), isTrue);
    });
  });

  group('EMVCo KHQR Generation', () {
    test('Generates valid Dynamic KHQR in USD', () {
      const request = KhqrPaymentRequest(
        accountInformation: '500050937@abaa',
        merchantId: 'ABA_STORE_001',
        merchantName: 'Digital Key Store',
        merchantCity: 'Phnom Penh',
        amount: 249.00,
        currency: KhqrCurrency.usd,
        billNumber: 'INV-2026-001',
        storeLabel: 'Online Shop',
        terminalLabel: 'API-01',
      );

      final result = KhqrGenerator.generateDynamicKhqr(request);

      expect(result.qrString, startsWith('000201010212'));
      expect(result.qrString, contains('5303840')); // USD code
      expect(result.qrString, contains('5406249.00')); // Amount formatted
      expect(result.qrString, contains('5802KH')); // Country code
      expect(
          result.qrString, contains('5917Digital Key Store')); // Merchant name
      expect(result.qrString, contains('6010Phnom Penh')); // City
      expect(result.qrString, contains('6304')); // CRC tag

      expect(result.crc.length, equals(4));
      expect(result.md5Hash.length, equals(32));
    });

    test('Generates valid Dynamic KHQR in KHR with integer formatting', () {
      const request = KhqrPaymentRequest(
        accountInformation: '500050937@abaa',
        merchantId: 'ABA_STORE_001',
        merchantName: 'Digital Key Store',
        merchantCity: 'Phnom Penh',
        amount: 1020000.0, // ~249 USD in KHR
        currency: KhqrCurrency.khr,
        billNumber: 'INV-2026-KHR',
      );

      final result = KhqrGenerator.generateDynamicKhqr(request);

      expect(result.qrString, contains('5303116')); // KHR code
      expect(result.qrString, contains('54071020000')); // Integer amount
    });
  });

  group('EMVCo Reverse TLV Parser', () {
    test('Parses generated payload and validates CRC checksum integrity', () {
      const request = KhqrPaymentRequest(
        accountInformation: 'lysokheng@aclb',
        merchantId: 'MKT_9988',
        merchantName: 'Codingate Store',
        merchantCity: 'Phnom Penh',
        amount: 49.99,
        currency: KhqrCurrency.usd,
        billNumber: 'BILL-4421',
      );

      final generated = KhqrGenerator.generateDynamicKhqr(request);
      final parsed = KhqrParser.parse(generated.qrString);

      expect(parsed.isValid, isTrue);
      expect(parsed.isCrcValid, isTrue);
      expect(parsed.merchantName, equals('Codingate Store'));
      expect(parsed.merchantCity, equals('Phnom Penh'));
      expect(parsed.accountInformation, equals('lysokheng@aclb'));
      expect(parsed.merchantId, equals('MKT_9988'));
      expect(parsed.amount, equals(49.99));
      expect(parsed.currency, equals(KhqrCurrency.usd));
      expect(parsed.billNumber, equals('BILL-4421'));
    });

    test('Flags tampered QR strings as invalid CRC', () {
      const request = KhqrPaymentRequest(
        accountInformation: '500050937@abaa',
        merchantId: 'ABA_STORE_001',
        merchantName: 'Digital Key Store',
        merchantCity: 'Phnom Penh',
        amount: 249.00,
        currency: KhqrCurrency.usd,
        billNumber: 'INV-001',
      );

      final generated = KhqrGenerator.generateDynamicKhqr(request);
      // Tamper amount from 249.00 to 001.00
      final tampered = generated.qrString.replaceAll('249.00', '001.00');

      final parsed = KhqrParser.parse(tampered);
      expect(parsed.isCrcValid, isFalse);
    });
  });

  group('Banking Deep-Link Dispatcher', () {
    const sampleQr =
        '00020101021229240015500050937@abaa0105STORE5802KH6304A1B2';

    test('Builds iOS banking schemes', () {
      final abaUri = KhqrDeepLinker.buildDeepLinkUri(
        bank: CambodianBankApp.aba,
        qrString: sampleQr,
        overrideIsIOS: true,
      );
      expect(abaUri, startsWith('aba://khqr?qr='));

      final wingUri = KhqrDeepLinker.buildDeepLinkUri(
        bank: CambodianBankApp.wing,
        qrString: sampleQr,
        overrideIsIOS: true,
      );
      expect(wingUri, startsWith('wing://khqr?qr='));
    });

    test('Builds Android intent URIs with correct package IDs', () {
      final abaUri = KhqrDeepLinker.buildDeepLinkUri(
        bank: CambodianBankApp.aba,
        qrString: sampleQr,
        overrideIsAndroid: true,
      );
      expect(abaUri, contains('package=com.ababank.aba_mobile'));
      expect(abaUri, contains('scheme=aba'));

      final acledaUri = KhqrDeepLinker.buildDeepLinkUri(
        bank: CambodianBankApp.acleda,
        qrString: sampleQr,
        overrideIsAndroid: true,
      );
      expect(acledaUri, contains('package=com.acledabank.acledatoanchet'));
    });

    test('Builds Universal Links fallback', () {
      final universalUri = KhqrDeepLinker.buildUniversalLink(
        bank: CambodianBankApp.bakong,
        qrString: sampleQr,
      );
      expect(universalUri, startsWith('https://bakong.nbc.gov.kh/pay?qr='));
    });
  });
}
