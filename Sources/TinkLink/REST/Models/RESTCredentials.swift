import Foundation

struct RESTCredentialsList: Decodable {
    let credentials: [RESTCredentials]
}

/// The credentials model represents a user's connected providers from where financial data is accessed.
struct RESTCredentials: Decodable {
    enum ModelType: String, DefaultableDecodable {
        case password = "PASSWORD"
        case mobileBankid = "MOBILE_BANKID"
        case keyfob = "KEYFOB"
        case thirdPartyApp = "THIRD_PARTY_APP"
        case unknown = "UNKNOWN"

        static var decodeFallbackValue: RESTCredentials.ModelType = .unknown
    }

    enum Status: String, DefaultableDecodable {
        case created = "CREATED"
        case authenticating = "AUTHENTICATING"
        case awaitingMobileBankidAuthentication = "AWAITING_MOBILE_BANKID_AUTHENTICATION"
        case awaitingSupplementalInformation = "AWAITING_SUPPLEMENTAL_INFORMATION"
        case updating = "UPDATING"
        case updated = "UPDATED"
        case authenticationError = "AUTHENTICATION_ERROR"
        case temporaryError = "TEMPORARY_ERROR"
        case permanentError = "PERMANENT_ERROR"
        case awaitingThirdPartyAppAuthentication = "AWAITING_THIRD_PARTY_APP_AUTHENTICATION"
        case deleted = "DELETED"
        case sessionExpired = "SESSION_EXPIRED"
        case unknown = "UNKNOWN"

        static var decodeFallbackValue: RESTCredentials.Status = .unknown
    }

    /// The unique identifier of the credentials.
    var id: String?

    /// The provider (financial institution) that the credentials is connected to.
    var providerName: String

    /// Indicates how Tink authenticates the user to the financial institution.
    var type: ModelType?

    /// The status indicates the state of the credentials. For some states there are actions which need to be performed on the credentials.
    var status: Status?

    /// A timestamp of when the credentials' status was last modified.
    var statusUpdated: Date?

    /// A user-friendly message connected to the status. Could be an error message or text describing what is currently going on in the refresh process.
    var statusPayload: String?

    /// A timestamp of when the credentials was the last time in status `UPDATED`.
    var updated: Date?

    /// This is a key-value map of `Field` name and value found on the `Provider` to which the credentials belongs to. This parameter is required when creating credentials.
    var fields: [String: String]

    /// A key-value structure to handle if status of credentials are `AWAITING_SUPPLEMENTAL_INFORMATION` or `AWAITING_THIRD_PARTY_APP_AUTHENTICATION`
    var supplementalInformation: String?

    /// (PSD2 change - Not yet implemented) - Indicates when the session of credentials with access type &#x60;OPEN_BANKING&#x60; will expire. After this date automatic refreshes will not be possible without new authentication from the user.
    var sessionExpiryDate: Date?

    /// The ID of the user that the credentials belongs to.
    var userId: String?
}
