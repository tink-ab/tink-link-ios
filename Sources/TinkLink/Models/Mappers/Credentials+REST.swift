import Foundation

extension Credentials {
    init(restCredentials: RESTCredentials) {
        guard let id = restCredentials.id, let type = restCredentials.type, let status = restCredentials.status else { fatalError() }
        //TODO: how to handle missing id?
        self.id = .init(id)
        self.providerID = .init(restCredentials.providerName)
        self.kind = .init(restCredentialType: type)
        self.status = .init(restCredentialsStatus: status)
        self.statusPayload = restCredentials.statusPayload ?? ""
        self.statusUpdated = restCredentials.statusUpdated
        self.updated = restCredentials.updated
        self.fields = restCredentials.fields
        self.supplementalInformationFields = restCredentials.supplementalInformation?.fields.map(Provider.FieldSpecification.init) ?? []
        self.thirdPartyAppAuthentication = nil //restCredentials.supplementalInformation
        self.sessionExpiryDate = restCredentials.sessionExpiryDate
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
        }
    }
}
