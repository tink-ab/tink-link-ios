import Foundation

protocol DefaultableCodable: Codable, RawRepresentable where RawValue: Decodable {
    static var defaultValue: Self { get set }
}

extension DefaultableCodable {
    init(from decoder: Decoder) throws {
        self = try Self(rawValue: decoder.singleValueContainer().decode(RawValue.self)) ?? Self.defaultValue
    }
}
