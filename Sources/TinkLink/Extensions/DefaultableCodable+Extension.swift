import Foundation

protocol DefaultableDecodable: Decodable, RawRepresentable where RawValue: Decodable {
    static var decodeFallbackValue: Self { get set }
}

extension DefaultableDecodable {
    init(from decoder: Decoder) throws {
        let decodedStringValue = try decoder.singleValueContainer().decode(RawValue.self)
        self = Self(rawValue: decodedStringValue) ?? Self.decodeFallbackValue
    }
}
