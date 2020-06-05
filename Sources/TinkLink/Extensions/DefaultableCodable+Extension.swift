import Foundation

protocol DefaultableDecodable: Decodable, RawRepresentable where RawValue: Decodable {
    static var decodeFallbackValue: Self { get set }
}

extension DefaultableDecodable {
    init(from decoder: Decoder) throws {
        self = try Self(rawValue: decoder.singleValueContainer().decode(RawValue.self)) ?? Self.decodeFallbackValue
    }
}
