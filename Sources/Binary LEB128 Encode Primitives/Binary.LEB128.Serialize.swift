// Binary.LEB128.Serialize.swift
// swift-binary-leb128-primitives
//
// LEB128 serialization via Array init extensions.

public import Byte_Primitives

extension Array where Element == Byte {
    /// Creates a byte array containing the LEB128 encoding of an unsigned integer.
    ///
    /// ## Example
    ///
    /// ```swift
    /// let bytes = [Byte](leb128: 624485 as UInt32)
    /// // [0xE5, 0x8E, 0x26]
    ///
    /// let small = [Byte](leb128: 127 as UInt8)
    /// // [0x7F] (single byte, MSB=0)
    ///
    /// let zero = [Byte](leb128: 0 as UInt64)
    /// // [0x00]
    /// ```
    @inlinable
    public init<T: UnsignedInteger & FixedWidthInteger>(leb128 value: T) {
        self = []
        var v = value
        repeat {
            var byte = Byte(UInt8(v & 0x7F))
            v >>= 7
            if v != 0 {
                byte |= 0x80  // Set continuation bit
            }
            self.append(byte)
        } while v != 0
    }

    /// Creates a byte array containing the LEB128 encoding of a signed integer.
    ///
    /// Uses sign-aware encoding where negative values use two's complement
    /// representation with sign extension.
    ///
    /// ## Example
    ///
    /// ```swift
    /// let negative = [Byte](leb128: -1 as Int8)
    /// // [0x7F] (single byte with sign bit set)
    ///
    /// let positive = [Byte](leb128: 127 as Int32)
    /// // [0xFF, 0x00] (needs extra byte to distinguish from -1)
    ///
    /// let large = [Byte](leb128: -624485 as Int64)
    /// // [0x9B, 0xF1, 0x59]
    /// ```
    @inlinable
    public init<T: SignedInteger & FixedWidthInteger>(leb128 value: T) {
        self = []
        var v = value
        var more = true
        while more {
            var byte = Byte(UInt8(truncatingIfNeeded: v & 0x7F))
            v >>= 7  // Arithmetic shift for sign extension
            // Continue if value isn't fully encoded (sign-aware termination)
            let signBit = (byte & 0x40) != 0
            if (v == 0 && !signBit) || (v == -1 && signBit) {
                more = false
            } else {
                byte |= 0x80  // Set continuation bit
            }
            self.append(byte)
        }
    }
}
