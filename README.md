# Binary LEB128 Primitives

![Development Status](https://img.shields.io/badge/status-active--development-blue.svg)

LEB128 (Little-Endian Base 128) variable-length integer serialization. Variable-length encoding used by DWARF debug info, WebAssembly binary format, and Protocol Buffers wire format.

This package ships only the **serialization** half (`[UInt8].init(leb128:)` for both signed and unsigned integers). The parsing half lives in [`swift-binary-parser-primitives/Sources/Binary LEB128 Parser Primitives/`](https://github.com/swift-primitives/swift-binary-parser-primitives) and consumes this package.

---

## Key Features

- **Serialization-only L1 leaf** — depends only on `Binary Namespace` from `swift-binary-primitives`. No transitive surface beyond the namespace anchor.
- **Symmetric with the parser side** — `swift-binary-parser-primitives/Binary LEB128 Parser Primitives` provides the parser; this package provides the serializer. Mirrors the institute's `Parser.Protocol` / `Serializer.Protocol` separation per `canonical-witness-capability-attachment.md`.
- **Foundation-free** — pure stdlib (`UnsignedInteger`, `SignedInteger`, `FixedWidthInteger`, `Array<UInt8>`).
- **Multi-spec authority** — the LEB128 encoding mechanism is shared across DWARF v5 §7.6, WebAssembly Core 1.0 §5.2.2, and Protocol Buffers wire format (varint). L1 mechanism + L2 spec packages pattern.

---

## Quick Start

```swift
import Binary_LEB128_Primitives

// Unsigned encoding — the MSB of each byte is the continuation flag.
let bytes = [UInt8](leb128: 624485 as UInt32)
// [0xE5, 0x8E, 0x26]

let zero = [UInt8](leb128: 0 as UInt64)
// [0x00]

let small = [UInt8](leb128: 127 as UInt8)
// [0x7F]   (single byte, MSB = 0)

// Signed encoding — uses sign extension; the sign bit of the final byte is extended.
let negative = [UInt8](leb128: -1 as Int8)
// [0x7F]

let positive = [UInt8](leb128: 127 as Int32)
// [0xFF, 0x00]   (extra byte distinguishes from -1)
```

---

## Errors

`Binary.LEB128.Error` is the parsing-side error vocabulary; serialization is total (no failure modes for valid integer inputs).

```swift
public enum Binary.LEB128.Error: Swift.Error, Sendable, Equatable {
    case overflow(bitWidth: Int)   // The encoded value exceeds the target type's bit width.
    case unterminated              // The input ended before the final byte (missing byte with MSB=0).
}
```

---

## Architecture

LEB128 is a serialization mechanism, not a spec. Multiple specifications use it:

- **DWARF v5 §7.6** — debug information format.
- **WebAssembly Core 1.0 §5.2.2** — binary format integers.
- **Protocol Buffers wire format** — Google calls them "varints" but the encoding is LEB128.

This package owns the bit-level mechanism. Spec packages that consume LEB128 (a future `swift-dwarf-leb128`, `swift-wasm-leb128`, or unified spec packages with their own naming) build on top of this primitive.

The L1 mechanism + L2 spec packages pattern is identical to the swift-binary-base-primitives + swift-rfc-4648 architecture per `swift-institute/Research/binary-base-n-rfc-4648-reconciliation.md`.

---

## Provenance

Split from `swift-binary-primitives/Sources/Binary LEB128 Primitives/` on 2026-05-07 per [`swift-institute/Research/binary-primitives-package-decomposition.md`](https://github.com/swift-institute) (RECOMMENDATION, Tier 2). The split mirrors the precedent set earlier the same day by [`swift-binary-base-primitives`](https://github.com/swift-primitives/swift-binary-base-primitives), itself authored per [`swift-institute/Research/binary-base-n-encoding-family-architecture.md`](https://github.com/swift-institute).
