import Foundation

struct AnyEncodable: Encodable {
    var encodable: Encodable

    init<E: Encodable>(_ encodable: E) {
        self.encodable = encodable
    }

    func encode(to encoder: Encoder) throws {
        try encodable.encode(to: encoder)
    }
}
