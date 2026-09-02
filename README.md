# Binary LEB128 Primitives

![Development Status](https://img.shields.io/badge/status-active--development-blue.svg)

LEB128 (Little-Endian Base 128) variable-length integer encoding — the shared encode and decode codec mechanism over `Byte`, the format used by DWARF debug info, the WebAssembly binary format, and Protocol Buffers varints.

---

## Quick Start

Encoding packs a fixed-width integer into the minimal LEB128 byte sequence. The MSB of each byte is the continuation flag; signed values sign-extend the final byte.

```swift
import Binary_LEB128_Primitives

// Unsigned — 7 payload bits per byte, MSB set while more bytes follow.
let bytes = [Byte](leb128: 624485 as UInt32)
// [0xE5, 0x8E, 0x26]

let small = [Byte](leb128: 127 as UInt8)
// [0x7F]   (single byte, MSB clear)

// Signed — two's-complement with sign extension.
let negative = [Byte](leb128: -1 as Int8)
// [0x7F]

let positive = [Byte](leb128: 127 as Int32)
// [0xFF, 0x00]   (an extra byte distinguishes +127 from -1)
```

Decoding routes through one bit-width-parameterized core, `Binary.LEB128.Decode`. It is *step-based*: you feed payload bytes one at a time, holding your own accumulator and shift, and the fold returns `true` on the final byte. This is the single decode arithmetic every LEB128 reader in the ecosystem delegates to, so a borrowed zero-copy cursor and a plain `[UInt8]` driver share identical overflow behaviour.

```swift
import Binary_LEB128_Primitives

func decode(_ encoded: [UInt8]) throws(Binary.LEB128.Error) -> UInt64 {
    var result: UInt64 = 0
    var shift = 0
    for byte in encoded {
        if try Binary.LEB128.Decode.unsigned(byte: byte, into: &result, shift: &shift) {
            return result
        }
    }
    throw .unterminated
}

let value = try decode([0xE5, 0x8E, 0x26])   // 624485
```

The decode contract is strict: a payload that cannot fit the target width is rejected the moment it appears (precise-fit), and an encoding that runs past the target width is rejected even when the trailing bytes are zero or sign padding (over-long). A canonical, minimal encoder never emits such bytes, so round-trips are unaffected — only malformed input is rejected, surfaced as `Binary.LEB128.Error.overflow(bitWidth:)` or `.unterminated`.

---

## Installation

```swift
dependencies: [
    .package(url: "https://github.com/swift-molecules/swift-binary-leb128.git", branch: "main")
]
```

```swift
.target(
    name: "App",
    dependencies: [
        .product(name: "Binary LEB128", package: "swift-binary-leb128"),
    ]
)
```

Requires Swift 6.3.1 and macOS 26 / iOS 26 / tvOS 26 / watchOS 26 / visionOS 26 (or the matching Linux / Windows toolchain).

---

## Architecture

LEB128 is a codec mechanism, not a specification. This package owns the bit-level arithmetic both directions share; spec packages (DWARF, WebAssembly, Protocol Buffers) build their named parsers on top of it. Four products, decomposed so consumers import only the direction they need.

| Product | Target | Purpose |
|---------|--------|---------|
| `Binary LEB128` | `Sources/Binary LEB128/` | The `Binary.LEB128` namespace and `Binary.LEB128.Error` (`overflow(bitWidth:)`, `unterminated`). |
| `Binary LEB128 Decode` | `Sources/Binary LEB128 Decode/` | `Binary.LEB128.Decode` — the single bit-width-parameterized decode core (`unsigned` / `signed` step folds). |
| `Binary LEB128 Encode` | `Sources/Binary LEB128 Encode/` | `[Byte].init(leb128:)` for unsigned and signed `FixedWidthInteger`s. |
| `Binary LEB128 Test Support` | `Tests/Support/` | Re-exports the namespace, decode core, and encoder for test consumers. |

Depends only on the `Binary` namespace anchor (`swift-binary`) and `Byte` (`swift-byte`). Foundation-free.

---

## Platform Support

| Platform | Status |
|----------|--------|
| macOS 26 | Full support |
| Linux | Full support |
| Windows | Full support |
| iOS / tvOS / watchOS / visionOS | Supported |

---

## Community

<!-- BEGIN: discussion -->
<!-- Discussion thread created at publication. -->
<!-- END: discussion -->

## License

Apache 2.0. See [LICENSE.md](LICENSE.md).
