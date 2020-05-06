import Foundation

public struct CurrencyCode: Hashable, ExpressibleByStringLiteral, Codable {
    let value: String

    init(_ value: String) {
        self.value = value
    }

    init(stringLiteral value: String) {
        self.value = value
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        self.value = try container.decode(String.self)
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(value)
    }
}

