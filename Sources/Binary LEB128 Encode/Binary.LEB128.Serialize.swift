public import Byte

extension Array where Element == Byte {

    @inlinable
    public init<T: UnsignedInteger & FixedWidthInteger>(leb128 value: T) {
        self = []
        var v = value
        repeat {
            var pattern = UInt8(v & 0x7F)
            v >>= 7
            if v != 0 {
                pattern |= 0x80
            }
            self.append(Byte(bitPattern: pattern))
        } while v != 0
    }

    @inlinable
    public init<T: SignedInteger & FixedWidthInteger>(leb128 value: T) {
        self = []
        var v = value
        var more = true
        while more {
            var pattern = UInt8(truncatingIfNeeded: v & 0x7F)
            v >>= 7

            let signBit = (pattern & 0x40) != 0
            if (v == 0 && !signBit) || (v == -1 && signBit) {
                more = false
            } else {
                pattern |= 0x80
            }
            self.append(Byte(bitPattern: pattern))
        }
    }
}
