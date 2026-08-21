public import Byte_Primitives

extension Array where Element == Byte {

    @inlinable
    public init<T: UnsignedInteger & FixedWidthInteger>(leb128 value: T) {
        self = []
        var v = value
        repeat {
            var byte = Byte(UInt8(v & 0x7F))
            v >>= 7
            if v != 0 {
                byte |= 0x80
            }
            self.append(byte)
        } while v != 0
    }

    @inlinable
    public init<T: SignedInteger & FixedWidthInteger>(leb128 value: T) {
        self = []
        var v = value
        var more = true
        while more {
            var byte = Byte(UInt8(truncatingIfNeeded: v & 0x7F))
            v >>= 7

            let signBit = (byte & 0x40) != 0
            if (v == 0 && !signBit) || (v == -1 && signBit) {
                more = false
            } else {
                byte |= 0x80
            }
            self.append(byte)
        }
    }
}
