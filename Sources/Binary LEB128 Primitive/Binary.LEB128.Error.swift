extension Binary.LEB128 {

    public enum Error: Swift.Error, Sendable, Equatable {

        case overflow(bitWidth: Int)

        case unterminated
    }
}

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
