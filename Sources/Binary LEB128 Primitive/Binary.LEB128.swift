// Binary.LEB128.swift
// swift-binary-leb128-primitives
//
// Namespace for LEB128 (Little-Endian Base 128) variable-length integer encoding.

extension Binary {
    /// Variable-length integer encoding using 7 bits per byte.
    ///
    /// LEB128 encodes integers using continuation bits: the MSB of each byte
    /// indicates whether more bytes follow (1) or this is the final byte (0).
    ///
    /// Used in WebAssembly, DWARF debugging format, and Protocol Buffers.
    ///
    /// ## Unsigned Encoding
    ///
    /// Each byte stores 7 bits of the value. The MSB is the continuation flag.
    ///
    /// ```
    /// Value: 624485 (0x98765)
    /// Binary: 10011000 01110110 0101
    ///
    /// LEB128: 11100101 10001110 00100110
    ///         ↑        ↑        ↑
    ///         continue continue final
    /// ```
    ///
    /// ## Signed Encoding
    ///
    /// Uses sign extension. The sign bit of the final byte is extended.
    ///
    /// ## Example
    ///
    /// ```swift
    /// // Serialization (this module)
    /// let bytes = [UInt8](leb128: 624485 as UInt32)
    /// // [0xE5, 0x8E, 0x26]
    ///
    /// // Parsing (swift-binary-parser-primitives → Binary LEB128 Parser Primitives)
    /// let parser = Binary.LEB128.Unsigned<UInt64>()
    /// var input: ArraySlice<UInt8> = [0xE5, 0x8E, 0x26][...]
    /// let value = try parser.parse(&input)  // 624485
    /// ```
    public enum LEB128 {}
}
