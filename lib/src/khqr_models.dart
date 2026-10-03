/// Supported transaction currencies in the Bakong payment ecosystem.
enum KhqrCurrency {
  usd('840', 'USD'),
  khr('116', 'KHR');

  final String code;
  final String symbol;
  const KhqrCurrency(this.code, this.symbol);

  static KhqrCurrency fromCode(String code) {
    return KhqrCurrency.values.firstWhere(
      (c) => c.code == code,
      orElse: () => KhqrCurrency.usd,
    );
  }
}

/// Dynamic payment request model containing transaction metadata.
class KhqrPaymentRequest {
  /// Merchant Bakong Account ID (e.g. "500050937@abaa" or phone number).
  final String accountInformation;

  /// Unique Merchant Identifier code.
  final String merchantId;

  /// Display name of the merchant (Tag 59). Max 25 chars.
  final String merchantName;

  /// Merchant City (Tag 60). e.g. "Phnom Penh". Max 15 chars.
  final String merchantCity;

  /// Transaction amount (e.g. 10.50). Formatted to 2 decimal places for USD, whole number for KHR.
  final double amount;

  /// Transaction currency (USD or KHR).
  final KhqrCurrency currency;

  /// Unique order/invoice bill number (Tag 62 Sub-tag 01).
  final String billNumber;

  /// Optional Store Label (Tag 62 Sub-tag 03).
  final String? storeLabel;

  /// Optional Terminal Label (Tag 62 Sub-tag 07).
  final String? terminalLabel;

  /// Optional customer or merchant mobile contact (Tag 62 Sub-tag 02).
  final String? mobileNumber;

  /// Optional acquire bank code (Tag 29 Sub-tag 02).
  final String? acquiringBank;

  const KhqrPaymentRequest({
    required this.accountInformation,
    required this.merchantId,
    required this.merchantName,
    required this.merchantCity,
    required this.amount,
    required this.currency,
    required this.billNumber,
    this.storeLabel,
    this.terminalLabel,
    this.mobileNumber,
    this.acquiringBank,
  });
}

/// Resulting generated payload containing EMVCo QR string, MD5 hash, and CRC checksum.
class KhqrPayloadResult {
  /// The full EMVCo compliant TLV QR string ready to render as QR image.
  final String qrString;

  /// MD5 hash of the payload string for indexing and idempotency tracking.
  final String md5Hash;

  /// 4-character hex CRC-16 checksum.
  final String crc;

  /// Timestamp when payload was generated.
  final DateTime createdAt;

  const KhqrPayloadResult({
    required this.qrString,
    required this.md5Hash,
    required this.crc,
    required this.createdAt,
  });

  @override
  String toString() => qrString;
}

/// Parsed data structure extracted from an EMVCo QR string.
class KhqrParsedData {
  final bool isValid;
  final String? crc;
  final bool isCrcValid;
  final String? merchantName;
  final String? merchantCity;
  final String? accountInformation;
  final String? merchantId;
  final double? amount;
  final KhqrCurrency? currency;
  final String? billNumber;
  final String? storeLabel;
  final String? terminalLabel;
  final Map<String, String> rawTags;

  const KhqrParsedData({
    required this.isValid,
    required this.isCrcValid,
    this.crc,
    this.merchantName,
    this.merchantCity,
    this.accountInformation,
    this.merchantId,
    this.amount,
    this.currency,
    this.billNumber,
    this.storeLabel,
    this.terminalLabel,
    this.rawTags = const {},
  });
}

/// Cambodian banking apps supporting direct KHQR deep-linking.
enum CambodianBankApp {
  aba(
    name: 'ABA Mobile',
    iosScheme: 'aba:',
    androidPackage: 'com.ababank.aba_mobile',
    universalPrefix: 'https://link.payway.com.kh/app',
  ),
  wing(
    name: 'Wing Bank',
    iosScheme: 'wing:',
    androidPackage: 'com.wingmoney.wingpay',
    universalPrefix: 'https://wingmoney.com/pay',
  ),
  acleda(
    name: 'Acleda ToanChet',
    iosScheme: 'acledatoanchet:',
    androidPackage: 'com.acledabank.acledatoanchet',
    universalPrefix: 'https://acledabank.com.kh/app',
  ),
  bakong(
    name: 'National Bakong App',
    iosScheme: 'bakong:',
    androidPackage: 'kh.gov.nbc.bakong',
    universalPrefix: 'https://bakong.nbc.gov.kh/pay',
  );

  final String name;
  final String iosScheme;
  final String androidPackage;
  final String universalPrefix;

  const CambodianBankApp({
    required this.name,
    required this.iosScheme,
    required this.androidPackage,
    required this.universalPrefix,
  });
}
