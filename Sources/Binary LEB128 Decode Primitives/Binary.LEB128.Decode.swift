// Binary.LEB128.Decode.swift
// swift-binary-leb128-primitives
//
// The single, bit-width-parameterized LEB128 decode core. This is the one
// shared decode arithmetic for every LEB128 decoder in the ecosystem:
//   - the canonical `Parser.\`Protocol\`` structs `Binary.LEB128.Unsigned`/`.Signed`
//     (in swift-binary-leb128-parser-primitives), and
//   - the binary `Machine`/`Borrowed` interpreters' `.uleb128`/`.sleb128`
//     instructions (in swift-binary-parser-primitives).
//
// ## Step-based by design
//
// Each call site feeds payload bytes ONE AT A TIME and keeps its own
// byte-fetch loop. This is what lets the core serve the zero-copy borrowed
// interpreter: that path holds a `~Escapable Cursor<Byte>` it cannot pass
// `inout` to a function (Swift 6.x treats it as an escape), but it CAN copy a
// `UInt8` out and pass it plus `inout` POD scalars. The `Byte -> UInt8` bridge
// happens once at each site's unpacking boundary per [API-BYTE-004].
//
// ## Overflow contract (canonical, STRICT)
//
// Two rejections, width-general:
//   1. Precise-fit — within the target width, a payload that cannot fit the
//      remaining bits is rejected the moment it appears (any byte position).
//   2. Over-long — an encoding that runs PAST the target width is rejected,
//      including otherwise-harmless zero/sign pad bytes. A canonical (minimal)
//      encoder never emits such bytes, so round-trips are unaffected; only
//      non-minimal / malformed input is rejected.
//
// Strict was chosen deliberately (principal, 2026-05-30) as the safe L1 default:
// WebAssembly mandates rejecting over-long encodings, and a lenient decoder
// silently accepts malformed input. This also matches the over-long strictness
// the binary Machine/Borrowed interpreters already had, so re-pointing them onto
// this core preserves their behavior; it tightens only the canonical parser
// structs, which previously accepted over-long pad bytes.

public import Binary_LEB128_Primitive

extension Binary.LEB128 {
    /// The shared LEB128 decode arithmetic.
    ///
    /// Drive a decode by repeatedly calling `unsigned(byte:into:shift:)` (or
    /// `signed`) with successive payload bytes until it returns `true` (the
    /// final byte, continuation bit clear). The accumulator and shift are the
    /// caller's locals; the core never touches the byte source.
    public enum Decode {}
}

extension Binary.LEB128.Decode {
    /// Folds one byte into an unsigned LEB128 accumulation.
    ///
    /// - Parameters:
    ///   - byte: The next encoded byte (continuation bit in 0x80, payload in 0x7F).
    ///   - result: The running accumulator; seed to `0` before the first byte.
    ///   - shift: The running bit offset; seed to `0` before the first byte.
    /// - Returns: `true` when this is the final byte (continuation bit clear).
    /// - Throws: `Binary.LEB128.Error.overflow` when the value exceeds `T`'s width.
    @inlinable
    public static func unsigned<T: UnsignedInteger & FixedWidthInteger>(
        byte: UInt8,
        into result: inout T,
        shift: inout Int
    ) throws(Binary.LEB128.Error) -> Bool {
        if shift >= T.bitWidth {
            // Over-long: this byte runs past the target width — reject (strict).
            throw .overflow(bitWidth: T.bitWidth)
        }
        let payload = T(byte & 0x7F)
        if shift > 0, payload > T.max >> shift {
            // Within width: reject a payload that won't fit the remaining bits.
            throw .overflow(bitWidth: T.bitWidth)
        }
        result |= payload << shift
        shift += 7
        return (byte & 0x80) == 0
    }

    /// Folds one byte into a signed (two's-complement) LEB128 accumulation.
    ///
    /// Sign extension is applied automatically when this returns `true`, so the
    /// caller only loops until the final byte — no separate finalize step.
    ///
    /// - Parameters:
    ///   - byte: The next encoded byte (continuation bit in 0x80, sign bit in 0x40).
    ///   - result: The running accumulator; seed to `0` before the first byte.
    ///   - shift: The running bit offset; seed to `0` before the first byte.
    /// - Returns: `true` when this is the final byte (continuation bit clear).
    /// - Throws: `Binary.LEB128.Error.overflow` when the value exceeds `T`'s width.
    @inlinable
    public static func signed<T: SignedInteger & FixedWidthInteger>(
        byte: UInt8,
        into result: inout T,
        shift: inout Int
    ) throws(Binary.LEB128.Error) -> Bool {
        if shift >= T.bitWidth {
            // Over-long: this byte runs past the target width — reject (strict).
            throw .overflow(bitWidth: T.bitWidth)
        }
        let done = (byte & 0x80) == 0
        if done, shift + 7 > T.bitWidth {
            // Precise-fit (straddle): this final byte's payload runs past the
            // target width. The bit that lands on T's sign position and every
            // bit above it (including the byte's own 0x40 sign flag) must all
            // agree with the sign the result will carry — the WebAssembly sN
            // unused-bits rule, the signed counterpart of unsigned's
            // `payload > T.max >> shift` precise-fit check.
            let fitBits = T.bitWidth - shift
            let region = (byte & 0x7F) >> (fitBits - 1)
            let regionWidth = 8 - fitBits
            let allOnes: UInt8 = (1 << regionWidth) - 1
            if region != 0, region != allOnes {
                throw .overflow(bitWidth: T.bitWidth)
            }
        }
        let payload = T(truncatingIfNeeded: byte & 0x7F)
        result |= payload << shift
        shift += 7
        if done, shift < T.bitWidth, (byte & 0x40) != 0 {
            // Final byte's sign bit set: extend the sign through the high bits.
            result |= T(-1) << shift
        }
        return done
    }
}
