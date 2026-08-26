public import Binary_LEB128_Primitive

extension Binary.LEB128 {

    public enum Decode {}
}

extension Binary.LEB128.Decode {

    @inlinable
    public static func unsigned<T: UnsignedInteger & FixedWidthInteger>(
        byte: UInt8,
        into result: inout T,
        shift: inout Int
    ) throws(Binary.LEB128.Error) -> Bool {
        if shift >= T.bitWidth {

            throw .overflow(bitWidth: T.bitWidth)
        }
        let payload = T(byte & 0x7F)
        if shift > 0, payload > T.max >> shift {

            throw .overflow(bitWidth: T.bitWidth)
        }
        result |= payload << shift
        shift += 7
        return (byte & 0x80) == 0
    }

    @inlinable
    public static func signed<T: SignedInteger & FixedWidthInteger>(
        byte: UInt8,
        into result: inout T,
        shift: inout Int
    ) throws(Binary.LEB128.Error) -> Bool {
        if shift >= T.bitWidth {

            throw .overflow(bitWidth: T.bitWidth)
        }
        let done = (byte & 0x80) == 0
        if done, shift + 7 > T.bitWidth {

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

            result |= T(-1) << shift
        }
        return done
    }
}
