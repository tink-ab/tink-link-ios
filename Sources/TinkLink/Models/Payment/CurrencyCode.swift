import Foundation

public struct CurrencyCode: Hashable, ExpressibleByStringLiteral {
    public let value: String

    public init(_ value: String) {
        self.value = value
    }

    public init(stringLiteral value: String) {
        self.value = value
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        self.value = try container.decode(String.self)
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(value)
    }
}

