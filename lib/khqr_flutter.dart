/// Production-Grade Bakong KHQR Generator, Parser & Mobile Banking Deep-Linker
///
/// Developed by Huot Lysokheng (Mobile Tech Lead & FinTech Architect)
///
/// Features:
/// - EMVCo Tag-Length-Value (TLV) payload generation for NBC Bakong KHQR.
/// - CRC16-CCITT (polynomial 0x1021) automated checksum engine.
/// - Dynamic (Tag 01: 12) and Static (Tag 01: 11) QR code generation.
/// - Support for USD (`840`) and KHR (`116`) currencies.
/// - Reverse TLV parser with CRC integrity validation.
/// - Deep-link URI generator for ABA Mobile, Wing Bank, Acleda ToanChet, and Bakong.
library khqr_flutter;

export 'src/khqr_models.dart';
export 'src/khqr_generator.dart';
export 'src/khqr_parser.dart';
export 'src/khqr_deep_linker.dart';
