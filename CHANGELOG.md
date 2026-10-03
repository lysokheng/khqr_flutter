## 1.0.0

- Initial stable release of `khqr_flutter`.
- EMVCo Tag-Length-Value (TLV) payload generation for Bakong KHQR.
- CRC16-CCITT (polynomial 0x1021) automated checksum engine.
- Dynamic (Tag 01: 12) and Static (Tag 01: 11) QR code generation.
- Support for USD (`840`) and KHR (`116`) currencies.
- Automated EMVCo QR string reverse parser (`KhqrParser.parse`) with CRC integrity validation.
- Mobile banking deep-link URI generator for ABA Mobile, Wing Bank, Acleda ToanChet, and National Bakong App.
- Zero external runtime dependencies.
