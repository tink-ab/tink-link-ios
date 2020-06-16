import Foundation

struct RESTSupplementalInformation: Codable {
    /// A key-value structure, use `value` from the fields found in `supplementalInformation` on the `Credentials` when status is `AWAITING_SUPPLEMENTAL_INFORMATION`.
    var information: [String: String]?

    init(information: [String: String]?) {
        self.information = information
    }
}
