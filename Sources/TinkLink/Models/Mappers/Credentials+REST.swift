import Foundation

extension Credentials {
    init(restCredentials: RESTCredentials) {
        guard let id = restCredentials.id, let type = restCredentials.type, let status = restCredentials.status else { fatalError() }
        self.id = .init(id)
        self.providerID = .init(restCredentials.providerName)
        self.kind = .init(restCredentialType: type)
        self.status = .init(restCredentialsStatus: status)
        self.statusPayload = restCredentials.statusPayload ?? ""
        self.statusUpdated = restCredentials.statusUpdated
        self.updated = restCredentials.updated
        self.fields = restCredentials.fields
        self.supplementalInformationFields = Self.makeFieldSpecifications(from: restCredentials.supplementalInformation)
        self.thirdPartyAppAuthentication = Self.makeThirdPartyAppAuthentication(from: restCredentials.supplementalInformation, id: id, status: restCredentials.status)
        self.sessionExpiryDate = restCredentials.sessionExpiryDate
    }

    static func makeFieldSpecifications(from string: String?) -> [Provider.FieldSpecification] {
        if let stringData = string?.data(using: .utf8),
            let fields = try? JSONDecoder().decode([RESTField].self, from: stringData) {
            return fields.map(Provider.FieldSpecification.init)
        }
        return []
    }

    static func makeThirdPartyAppAuthentication(from string: String?, id: String, status: RESTCredentials.Status?) -> Credentials.ThirdPartyAppAuthentication? {
        guard let status = status else {
            return nil
        }

        switch status {
        case .awaitingMobileBankidAuthentication:
            // Uses the same conversion as tink-backend: See https://github.com/tink-ab/tink-backend/blob/master/src/main/grpc-v1-lib/src/main/java/se/tink/backend/grpc/v1/converter/MobileBankIdAuthenticationPayload.java

            let deepLinkURL: URL?
            if let autostartToken = string {
                deepLinkURL = URL(string: "bankid:///?autostartToken=\(autostartToken)&redirect=tink://bankid/credentials/\(id)")
            } else {
                deepLinkURL = URL(string: "bankid:///?redirect=tink://bankid/credentials/\(id)")
            }

            return ThirdPartyAppAuthentication(
                downloadTitle: "Download Mobile BankID",
                downloadMessage: "You need to install the Mobile BankID app to authenticate",
                upgradeTitle: "",
                upgradeMessage: "",
                appStoreURL: URL(string: "itms://itunes.apple.com/se/app/bankid-sakerhetsapp/id433151512"),
                scheme: "bankid://",
                deepLinkURL: deepLinkURL)

        case .awaitingThirdPartyAppAuthentication:
            guard let payloadData = string?.data(using: .utf8),
                let payload = try? JSONDecoder().decode(RESTThirdPartyAppAuthenticationPayload.self, from: payloadData)
                else { return nil }

            return ThirdPartyAppAuthentication(
                downloadTitle: payload.downloadTitle,
                downloadMessage: payload.downloadMessage,
                upgradeTitle: payload.upgradeTitle,
                upgradeMessage: payload.upgradeMessage,
                appStoreURL: payload.ios.appStoreUrl,
                scheme: payload.ios.scheme,
                deepLinkURL: payload.ios.deepLinkUrl
            )
        default:
            return nil
        }
    }
}

extension Credentials.Kind {
    init(restCredentialType: RESTCredentials.ModelType) {
        switch restCredentialType {
        case .thirdPartyApp:
            self = .thirdPartyAuthentication
        case .password:
            self = .password
        case .mobileBankid:
            self = .mobileBankID
        case .keyfob:
            self = .keyfob
        case .unknown:
            self = .unknown
        }
    }

    init(restCredentialType: RESTProvider.CredentialsType) {
        switch restCredentialType {
        case .thirdPartyApp:
            self = .thirdPartyAuthentication
        case .password:
            self = .password
        case .mobileBankid:
            self = .mobileBankID
        case .keyfob:
            self = .keyfob
        case .fraud:
            self = .fraud
        case .unknown:
            self = .unknown
        }
    }

    var restCredentialsType: RESTCredentials.ModelType? {
        switch self {
        case .unknown:
            return nil
        case .password:
            return .password
        case .mobileBankID:
            return .mobileBankid
        case .keyfob:
            return .keyfob
        case .fraud:
            return nil
        case .thirdPartyAuthentication:
            return .thirdPartyApp
        }
    }
}

extension Credentials.Status {
    init(restCredentialsStatus: RESTCredentials.Status) {
        switch restCredentialsStatus {
        case .created:
            self = .created
        case .authenticating:
            self = .authenticating
        case .updating:
            self = .updating
        case .updated:
            self = .updated
        case .temporaryError:
            self = .temporaryError
        case .authenticationError:
            self = .authenticationError
        case .permanentError:
            self = .permanentError
        case .awaitingMobileBankidAuthentication:
            self = .awaitingMobileBankIDAuthentication
        case .awaitingSupplementalInformation:
            self = .awaitingSupplementalInformation
        case .awaitingThirdPartyAppAuthentication:
            self = .awaitingThirdPartyAppAuthentication
        case .sessionExpired:
            self = .sessionExpired
        case .deleted:
            self = .disabled
        case .unknown:
            self = .unknown
        }
    }
}
