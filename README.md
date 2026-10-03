# khqr_flutter

[![pub package](https://img.shields.io/badge/pub.dev-khqr__flutter-0175C2?logo=dart)](https://pub.dev/packages/khqr_flutter)
[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)](https://opensource.org/licenses/MIT)
[![Dart 3 Ready](https://img.shields.io/badge/Dart-3.0+-00B4AB.svg?logo=dart)](https://dart.dev)
[![PRs Welcome](https://img.shields.io/badge/PRs-welcome-brightgreen.svg)](https://github.com/lysokheng/khqr_flutter/pulls)

Production-grade **Bakong KHQR** dynamic/static QR generator, EMVCo Tag-Length-Value (TLV) reverse parser, CRC-16 CCITT checksum engine, and Cambodian mobile banking deep-link dispatcher for **Flutter & Dart**.

Developed by **[Huot Lysokheng](https://lysokheng.vercel.app/)** (Mobile Team Lead at Codingate & FinTech Architect).

---

## ⚡️ The Enterprise Production Kit

> **Building a commercial FinTech app or high-volume marketplace?**  
> Client-side QR generation is only 20% of the equation. To handle real money securely without duplicate payments or webhook race conditions, check out the **Production Bakong KHQR Enterprise Kit**:
>
> - ✅ **Node.js / TypeScript Webhook Server:** HMAC-SHA256 signature verification.
> - ✅ **Redis & BullMQ Idempotency Queue:** Zero double-crediting guarantee on network drops.
> - ✅ **Ready-to-Ship Flutter Modal UI:** Drop-in customizable checkout sheet with live payment listener.
> - ✅ **Mock Banking Simulator:** Local webhook trigger test suite without real funds.
>
> 👉 **[🇰🇭 Instant Checkout via Telegram (ABA KHQR - $249)](https://t.me/my_digital_keys_bot?start=prod_51)**  
> 👉 **[💳 International Card Checkout on Gumroad](https://lysoar2.gumroad.com/l/flutter-khqr-kit)**

---

## Features

- 🇰🇭 **National NBC EMVCo Standards:** Implements Tag 00, Tag 01, Tag 29, Tag 52, Tag 53, Tag 54, Tag 58, Tag 59, Tag 60, Tag 62, and Tag 63.
- 🧮 **Automated CRC-16 CCITT:** Polynomial `0x1021`, initial `0xFFFF` checksum calculation.
- 💵 **Multi-Currency Support:** USD (`840`, 2-decimal formatting) and KHR (`116`, whole-integer rounding).
- 🔍 **Reverse TLV Parser:** Reconstructs metadata and verifies CRC cryptographic integrity from raw scanned strings.
- 📱 **Mobile Banking Deep-Linking:** Direct deep-link URL building for:
  - **ABA Mobile** (`aba://khqr?qr=...`)
  - **Wing Bank** (`wing://khqr?qr=...`)
  - **Acleda ToanChet** (`acledatoanchet://khqr?qr=...`)
  - **National Bakong App** (`bakong://khqr?qr=...`)
- 🚀 **Zero Dependencies:** Pure Dart with standard `crypto` hashing. Runs seamlessly on iOS, Android, Web, macOS, Windows, Linux, and backend Dart Frog / Serverpod.

---

## Installation

Add `khqr_flutter` to your `pubspec.yaml`:

```yaml
dependencies:
  khqr_flutter: ^1.0.0
```

Or install via terminal:

```bash
dart pub add khqr_flutter
# or for Flutter projects:
flutter pub add khqr_flutter
```

---

## Quick Start

### 1. Generate a Dynamic KHQR Code

```dart
import 'package:khqr_flutter/khqr_flutter.dart';

void main() {
  const request = KhqrPaymentRequest(
    accountInformation: '500050937@abaa', // Bakong Account ID
    merchantId: 'STORE_001',
    merchantName: 'Digital Key Store',
    merchantCity: 'Phnom Penh',
    amount: 24.50,
    currency: KhqrCurrency.usd,
    billNumber: 'INV-2026-088',
    storeLabel: 'Downtown Branch',
  );

  final result = KhqrGenerator.generateDynamicKhqr(request);

  print('Render this in your QR widget:');
  print(result.qrString);
  print('CRC Checksum: ${result.crc}');
  print('MD5 Hash:     ${result.md5Hash}');
}
```

### 2. Reverse Parse & Verify Scanned QR Strings

```dart
final parsed = KhqrParser.parse(scannedString);

if (parsed.isValid && parsed.isCrcValid) {
  print('Merchant: ${parsed.merchantName}');
  print('Amount:   ${parsed.amount} ${parsed.currency?.symbol}');
  print('Account:  ${parsed.accountInformation}');
} else {
  print('Invalid or tampered KHQR code detected!');
}
```

### 3. Open Directly in Banking Apps (Deep-Linking)

```dart
// Launch ABA Mobile directly on customer's phone
final abaUri = KhqrDeepLinker.buildDeepLinkUri(
  bank: CambodianBankApp.aba,
  qrString: result.qrString,
);

// Launch using url_launcher
if (await canLaunchUrl(Uri.parse(abaUri))) {
  await launchUrl(Uri.parse(abaUri), mode: LaunchMode.externalApplication);
}
```

---

## Supported Cambodian Banking Rails

| Bank Institution | iOS Scheme | Android Package | Universal Prefix |
| :--- | :--- | :--- | :--- |
| **ABA Mobile** | `aba://khqr?qr=` | `com.ababank.aba_mobile` | `https://link.payway.com.kh/app` |
| **Wing Bank** | `wing://khqr?qr=` | `com.wingmoney.wingpay` | `https://wingmoney.com/pay` |
| **Acleda ToanChet** | `acledatoanchet://khqr?qr=` | `com.acledabank.acledatoanchet` | `https://acledabank.com.kh/app` |
| **National Bakong** | `bakong://khqr?qr=` | `kh.gov.nbc.bakong` | `https://bakong.nbc.gov.kh/pay` |

---

## Architecture: EMVCo TLV Specifications

```
Tag 00: Format Indicator (01)
Tag 01: Initiation Method (12 = Dynamic, 11 = Static)
Tag 29: Merchant Account Info (Sub-00: Bakong ID, Sub-01: Merchant ID)
Tag 52: Merchant Category Code (0000)
Tag 53: Currency (840 = USD, 116 = KHR)
Tag 54: Transaction Amount
Tag 58: Country Code (KH)
Tag 59: Merchant Name
Tag 60: Merchant City
Tag 62: Additional Data Template (Sub-01: Bill Number, Sub-03: Store)
Tag 63: CRC-16 Checksum (4 Hex Digits)
```

---

## Contributing & Issues

Contributions, bug reports, and PRs are welcome on [GitHub](https://github.com/lysokheng/khqr_flutter).

---

## Author & Commercial Support

**Huot Lysokheng**  
Mobile Team Lead, WebRTC & FinTech Architect  
- **Portfolio:** [lysokheng.vercel.app](https://lysokheng.vercel.app/)  
- **Telegram:** [@lysokheng_huot](https://t.me/lysokheng_huot)  
- **Starter Kits:** [Enterprise Flutter Starter Kits](https://t.me/my_digital_keys_bot?start=prod_51)
