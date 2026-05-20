// Binary.LEB128.Error.swift
// swift-binary-leb128-primitives
//
// Error type for LEB128 parsing operations.

extension Binary.LEB128 {
    /// Errors that can occur during LEB128 parsing.
    ///
    /// ## Example
    ///
    /// ```swift
    /// // With Binary Parsing Primitives
    /// do {
    ///     let parser = Binary.LEB128.Unsigned<UInt8>()
    ///     var input: ArraySlice<UInt8> = [0x80, 0x80, 0x01][...]
    ///     _ = try parser.parse(&input)
    /// } catch Binary.LEB128.Error.overflow(let bitWidth) {
    ///     print("Value exceeds \(bitWidth) bits")
    /// }
    /// ```
    public enum Error: Swift.Error, Sendable, Equatable {
        /// The encoded value exceeds the target type's bit width.
        ///
        /// - Parameter bitWidth: The maximum bit width of the target type.
        case overflow(bitWidth: Int)

        /// The input ended before the final byte (missing byte with MSB=0).
        case unterminated
    }
}

// MARK: - CustomStringConvertible

extension Binary.LEB128.Error: CustomStringConvertible {
    public var description: String {
        switch self {
        case .overflow(let bitWidth):
            return "LEB128 value exceeds \(bitWidth)-bit capacity"
        case .unterminated:
            return "LEB128 sequence incomplete (missing terminating byte)"
        }
    }
}
