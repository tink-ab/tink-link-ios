import Foundation

/// The credentials model represents users connected providers from where financial data is accessed.
public struct Credentials: Identifiable {
    /// A unique identifier of a `Credentials`.
    public struct ID: Hashable, ExpressibleByStringLiteral {
        public init(stringLiteral value: String) {
            self.value = value
        }

        public init(_ value: String) {
            self.value = value
        }

        public let value: String
    }

    /// The unique identifier of the credentials.
    public let id: ID

    /// The provider (financial institution) that the credentials is connected to.
    public let providerID: Provider.ID

    /// Indicates how Tink authenticates the user to a financial institution.
    public enum Kind: CustomStringConvertible {
        case unknown

        /// The user will authenticate the credentials with a password.
        case password

        /// The user will authenticate the credentials with Mobile BankID.
        case mobileBankID

        /// The user will authenticate the credentials with a Key Fob.
        case keyfob

        /// Fraud
        case fraud

        /// The user will authenticate the credentials with a third party app.
        case thirdPartyAuthentication

        public var description: String {
            switch self {
            case .unknown:
                return "Unknown"
            case .password:
                return "Password"
            case .mobileBankID:
                return "Mobile BankID"
            case .keyfob:
                return "Key Fob"
            case .fraud:
                return "Fraud"
            case .thirdPartyAuthentication:
                return "Third Party Authentication"
            }
        }

        var sortOrder: Int {
            switch self {
            case .mobileBankID:
                return 1
            case .password:
                return 2
            case .thirdPartyAuthentication:
                return 3
            case .keyfob:
                return 4
            case .fraud:
                return 5
            case .unknown:
                return 6
            }
        }
    }

    /// Indicates how Tink authenticates the user to the financial institution.
    public let kind: Credentials.Kind

    /// The status indicates the state of a credentials.
    public enum Status {
        case unknown

        /// The credentials was just created.
        case created

        /// The credentials is in the process of authenticating.
        case authenticating

        /// The credentials is done authenticating and is updating accounts and transactions.
        case updating

        /// The credentials has finished authenticating and updating accounts and transactions.
        case updated

        /// There was a temporary error, see `statusPayload` for text describing the error.
        case temporaryError

        /// There was an authentication error, see `statusPayload` for text describing the error.
        case authenticationError

        /// There was a permanent error, see `statusPayload` for text describing the error.
        case permanentError

        /// The credentials is awaiting authentication with Mobile BankID.
        /// - Note: Will be deprecated and replaced with `awaitingThirdPartyAppAuthentication`
        case awaitingMobileBankIDAuthentication

        /// The credentials is awaiting supplemental information.
        ///
        /// If the authentication flow requires multiple steps with input from the user, as for example a SMS OTP authentication flow,
        /// the client should expect the `awaitingSupplementalInformation` status on the credential.
        ///
        /// Create a `Form` with this credentials to let the user supplement the required information.
        case awaitingSupplementalInformation

        /// The credentials has been disabled.
        case disabled

        /// The credentials is awaiting authentication with a third party app.
        ///
        /// If a provider is using third party services in their authentication flow, the client
        /// should expect the `awaitingThirdPartyAppAuthentication` status on the credentials.
        /// In order for the aggregation of data to be successful, the system expects the third
        /// party authentication flow to be successful as well.
        ///
        /// To handle this status, check `thirdPartyAppAuthentication` to get a deeplink url to the third party app and open it so the user can authenticate.
        /// If the app can't open the deeplink, ask the user to to download or upgrade the app from the AppStore.
        case awaitingThirdPartyAppAuthentication

        /// The credentials' session has expired, check `sessionExpiryDate` to see when it expired.
        case sessionExpired
    }

    /// The status indicates the state of a credentials. For some states there are actions which need to be performed on the credentials.
    public let status: Status

    /// A user-friendly message connected to the status. Could be an error message or text describing what is currently going on in the refresh process.
    public let statusPayload: String

    /// A timestamp of when the credentials' status was last modified.
    public let statusUpdated: Date?

    /// A timestamp of when the credentials was the last time in status `.updated`.
    public let updated: Date?

    /// This is a key-value map of Field name and value found on the Provider to which the credentials belongs to.
    public let fields: [String: String]

    /// A key-value structure to handle if status of credentials are `Credential.Status.awaitingSupplementalInformation`.
    internal let supplementalInformationFields: [Provider.FieldSpecification]

    /// Information about the third party authentication app.
    ///
    /// The ThirdPartyAppAuthentication contains specific deeplink urls and configuration for the third party app.
    public struct ThirdPartyAppAuthentication {
        /// Title of the app to be downloaded.
        public let downloadTitle: String?

        /// Detailed message about app to be downloaded.
        public let downloadMessage: String?

        /// Title of the app to be upgraded.
        public let upgradeTitle: String?

        /// Detailed message about app to be upgraded
        public let upgradeMessage: String?

        /// URL to AppStore where the app can be downloaded on iOS.
        public let appStoreURL: URL?

        /// Base scheme of the app on iOS.
        public let scheme: String?

        /// URL that the app should open on iOS. Can be of another scheme than app scheme.
        public let deepLinkURL: URL?

        public var hasAutoStartToken: Bool {
            deepLinkURL?.query?.contains("autostartToken") ?? false
        }
    }

    /// Information about the third party authentication flow.
    public let thirdPartyAppAuthentication: ThirdPartyAppAuthentication?

    /// Indicates when the session of credentials with access type `Provider.AccessType.openBanking` will expire. After this date automatic refreshes will not be possible without new authentication from the user.
    public let sessionExpiryDate: Date?
}
