import Binary_LEB128
import Binary_LEB128_Test_Support
import Byte
import Testing

private func decodeUnsigned<T: UnsignedInteger & FixedWidthInteger>(
    _ bytes: [UInt8],
    _ type: T.Type
) throws(Binary.LEB128.Error) -> T {
    var result: T = 0
    var shift = 0
    for byte in bytes {
        if try Binary.LEB128.Decode.unsigned(byte: byte, into: &result, shift: &shift) {
            return result
        }
    }
    throw .unterminated
}

private func decodeSigned<T: SignedInteger & FixedWidthInteger>(
    _ bytes: [UInt8],
    _ type: T.Type
) throws(Binary.LEB128.Error) -> T {
    var result: T = 0
    var shift = 0
    for byte in bytes {
        if try Binary.LEB128.Decode.signed(byte: byte, into: &result, shift: &shift) {
            return result
        }
    }
    throw .unterminated
}

private func encoded<T: UnsignedInteger & FixedWidthInteger>(_ value: T) -> [UInt8] {
    [Byte](leb128: value).map(\.bitPattern)
}

private func encoded<T: SignedInteger & FixedWidthInteger>(_ value: T) -> [UInt8] {
    [Byte](leb128: value).map(\.bitPattern)
}

extension Binary.LEB128.Decode {
    @Suite("Binary.LEB128.Decode") struct Test {
        @Suite struct Unit {}
        @Suite struct `Edge Case` {}
    }
}

extension Binary.LEB128.Decode.Test.Unit {

    @Test
    func `decode unsigned known sequences`() throws {
        #expect(try decodeUnsigned([0x00], UInt64.self) == 0)
        #expect(try decodeUnsigned([0x01], UInt64.self) == 1)
        #expect(try decodeUnsigned([0x7F], UInt64.self) == 127)
        #expect(try decodeUnsigned([0x80, 0x01], UInt64.self) == 128)
        #expect(try decodeUnsigned([0xAC, 0x02], UInt64.self) == 300)
        #expect(try decodeUnsigned([0xE5, 0x8E, 0x26], UInt64.self) == 624485)
    }

    @Test
    func `decode signed known sequences`() throws {
        #expect(try decodeSigned([0x00], Int64.self) == 0)
        #expect(try decodeSigned([0x01], Int64.self) == 1)
        #expect(try decodeSigned([0x3F], Int64.self) == 63)
        #expect(try decodeSigned([0x7F], Int64.self) == -1)
        #expect(try decodeSigned([0x7E], Int64.self) == -2)
        #expect(try decodeSigned([0x40], Int64.self) == -64)
        #expect(try decodeSigned([0x80, 0x7F], Int64.self) == -128)
    }

    @Test
    func `round-trips unsigned across widths`() throws {
        for v in [0, 1, 127, 128, 200, 255] as [UInt8] {
            #expect(try decodeUnsigned(encoded(v), UInt8.self) == v)
        }
        for v in [0, 1, 127, 128, 300, 16384, 65535] as [UInt16] {
            #expect(try decodeUnsigned(encoded(v), UInt16.self) == v)
        }
        for v in [0, 1, 624485, UInt32.max] as [UInt32] {
            #expect(try decodeUnsigned(encoded(v), UInt32.self) == v)
        }
        for v in [0, 1, 624485, UInt64.max] as [UInt64] {
            #expect(try decodeUnsigned(encoded(v), UInt64.self) == v)
        }
    }

    @Test
    func `round-trips signed across widths`() throws {
        for v in [0, 1, -1, 63, -64, Int8.min, Int8.max] as [Int8] {
            #expect(try decodeSigned(encoded(v), Int8.self) == v)
        }
        for v in [0, 1, -1, 127, -128, -624485, Int32.min, Int32.max] as [Int32] {
            #expect(try decodeSigned(encoded(v), Int32.self) == v)
        }
        for v in [0, 1, -1, -624485, Int64.min, Int64.max] as [Int64] {
            #expect(try decodeSigned(encoded(v), Int64.self) == v)
        }
    }
}

extension Binary.LEB128.Decode.Test.`Edge Case` {

    @Test
    func `unsigned rejects value past target width`() {

        #expect(throws: Binary.LEB128.Error.overflow(bitWidth: 8)) {
            try decodeUnsigned([0x80, 0x02], UInt8.self)
        }
    }

    @Test
    func `unsigned precise-fit catches narrow-width overflow before bit 64`() {

        #expect(throws: Binary.LEB128.Error.overflow(bitWidth: 16)) {
            try decodeUnsigned([0xFF, 0xFF, 0x07], UInt16.self)
        }
    }

    @Test
    func `unterminated when continuation bit never clears`() {
        #expect(throws: Binary.LEB128.Error.unterminated) {
            try decodeUnsigned([0x80, 0x80, 0x80], UInt64.self)
        }
    }

    @Test
    func `over-long encoding past width is rejected (strict)`() {

        #expect(throws: Binary.LEB128.Error.overflow(bitWidth: 8)) {
            try decodeUnsigned([0x80, 0x80, 0x00], UInt8.self)
        }
    }

    @Test
    func `decodes type maxima and minima round-trip`() throws {
        #expect(try decodeUnsigned(encoded(UInt8.max), UInt8.self) == UInt8.max)
        #expect(try decodeUnsigned(encoded(UInt64.max), UInt64.self) == UInt64.max)
        #expect(try decodeSigned(encoded(Int64.min), Int64.self) == Int64.min)
        #expect(try decodeSigned(encoded(Int64.max), Int64.self) == Int64.max)
    }

    @Test
    func `signed rejects final byte straddling width with mismatched sign (positive overflow)`() {

        #expect(throws: Binary.LEB128.Error.overflow(bitWidth: 8)) {
            try decodeSigned([0x80, 0x01], Int8.self)
        }
    }

    @Test
    func `signed rejects final byte straddling width with mismatched sign (negative overflow)`() {

        #expect(throws: Binary.LEB128.Error.overflow(bitWidth: 8)) {
            try decodeSigned([0xFF, 0x7E], Int8.self)
        }
    }

    @Test
    func `signed rejects wide straddle past Int64 width`() {

        #expect(throws: Binary.LEB128.Error.overflow(bitWidth: 64)) {
            try decodeSigned(Array(repeating: 0x80, count: 9) + [0x01], Int64.self)
        }
    }
}
