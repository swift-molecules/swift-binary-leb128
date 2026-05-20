# Changelog

All notable changes to `swift-binary-leb128-primitives` are documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/), and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Added

- Initial split from `swift-binary-primitives` per `swift-institute/Research/binary-primitives-package-decomposition.md` (RECOMMENDATION, 2026-05-07).
- `Binary.LEB128` namespace + `Binary.LEB128.Error` type (`.overflow(bitWidth:)`, `.unterminated`).
- Unsigned LEB128 serialization via `[UInt8].init(leb128:)` for `T: UnsignedInteger & FixedWidthInteger`.
- Signed LEB128 serialization via `[UInt8].init(leb128:)` for `T: SignedInteger & FixedWidthInteger`.

### Notes

- Parsing-side LEB128 lives in `swift-binary-parser-primitives/Sources/Binary LEB128 Parser Primitives/`. The Parser/Serializer split is intentional and symmetric with the institute's `Parser.Protocol` / `Serializer.Protocol` separation.
- This package depends only on `swift-binary-primitives`'s `Binary Namespace` target — it does NOT pull in the broader `Binary Primitives Core` substrate. Consumers needing both should import each explicitly.
