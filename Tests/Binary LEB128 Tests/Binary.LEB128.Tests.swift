import Binary_LEB128
import Binary_LEB128_Test_Support
import Byte
import Testing

extension Binary.LEB128 {
    @Suite("Binary.LEB128") struct Test {
        @Suite struct Unit {}
        @Suite struct `Edge Case` {}
        @Suite struct Integration {}
        @Suite(.serialized) struct Performance {}
    }
}

extension Binary.LEB128.Test.Unit {

    @Test
    func `serialize unsigned single byte`() {
        #expect([Byte](leb128: 0 as UInt32) == [0x00])
        #expect([Byte](leb128: 1 as UInt32) == [0x01])
        #expect([Byte](leb128: 127 as UInt32) == [0x7F])
    }

    @Test
    func `serialize unsigned multi-byte`() {
        #expect([Byte](leb128: 128 as UInt32) == [0x80, 0x01])
        #expect([Byte](leb128: 624485 as UInt32) == [0xE5, 0x8E, 0x26])
        #expect([Byte](leb128: 300 as UInt32) == [0xAC, 0x02])
    }

    @Test
    func `serialize signed positive`() {
        #expect([Byte](leb128: 0 as Int32) == [0x00])
        #expect([Byte](leb128: 1 as Int32) == [0x01])
        #expect([Byte](leb128: 63 as Int32) == [0x3F])
    }

    @Test
    func `serialize signed negative`() {
        #expect([Byte](leb128: -1 as Int32) == [0x7F])
        #expect([Byte](leb128: -2 as Int32) == [0x7E])
        #expect([Byte](leb128: -64 as Int32) == [0x40])
        #expect([Byte](leb128: -128 as Int32) == [0x80, 0x7F])
    }
}

extension Binary.LEB128.Test.`Edge Case` {

    @Test
    func `error is Sendable`() async {
        let error: Binary.LEB128.Error = .overflow(bitWidth: 8)
        let task = Task { error }
        let received = await task.value
        #expect(received == .overflow(bitWidth: 8))
    }

    @Test
    func `error is Equatable`() {
        #expect(Binary.LEB128.Error.unterminated == Binary.LEB128.Error.unterminated)
        #expect(
            Binary.LEB128.Error.overflow(bitWidth: 8) == Binary.LEB128.Error.overflow(bitWidth: 8)
        )
        #expect(
            Binary.LEB128.Error.overflow(bitWidth: 8) != Binary.LEB128.Error.overflow(bitWidth: 16)
        )
        #expect(Binary.LEB128.Error.unterminated != Binary.LEB128.Error.overflow(bitWidth: 8))
    }
}
