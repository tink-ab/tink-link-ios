import Foundation

extension Credential {
    init(grpcCredential: GRPCCredential) {
        self.id = .init(grpcCredential.id)
        self.providerID = .init(grpcCredential.providerName)
        self.kind = .init(grpcCredentialType: grpcCredential.type)
        self.status = .init(grpcCredentialStatus: grpcCredential.status)
        self.statusPayload = grpcCredential.statusPayload
        self.statusUpdated = grpcCredential.hasStatusUpdated ? grpcCredential.statusUpdated.date : nil
        self.updated = grpcCredential.hasUpdated ? grpcCredential.updated.date : nil
        self.fields = grpcCredential.fields
        self.supplementalInformationFields = grpcCredential.supplementalInformationFields.map(Provider.FieldSpecification.init(grpcProviderFieldSpecification:))
        self.thirdPartyAppAuthentication = grpcCredential.hasThirdPartyAppAuthentication ? ThirdPartyAppAuthentication(grpcThirdPartyAppAuthentication: grpcCredential.thirdPartyAppAuthentication) : nil
        self.sessionExpiryDate = grpcCredential.hasSessionExpiryDate ? grpcCredential.sessionExpiryDate.date : nil
    }
}

extension Credential.Kind {
    init(grpcCredentialType: GRPCCredential.TypeEnum) {
        switch grpcCredentialType {
        case .unknown:
            self = .unknown
        case .password:
            self = .password
        case .mobileBankid:
            self = .mobileBankID
        case .keyfob:
            self = .keyfob
        case .fraud:
            self = .fraud
        case .thirdPartyAuthentication:
            self = .thirdPartyAuthentication
        case .UNRECOGNIZED(let value):
            assertionFailure("Unrecognized type: \(value)")
            self = .unknown
        }
    }

    var grpcCredentialType: GRPCCredential.TypeEnum {
        switch self {
        case .unknown:
            return .unknown
        case .password:
            return .password
        case .mobileBankID:
            return .mobileBankid
        case .keyfob:
            return .keyfob
        case .fraud:
            return .fraud
        case .thirdPartyAuthentication:
            return .thirdPartyAuthentication
        }
    }
}

extension Credential.Status {
    init(grpcCredentialStatus: GRPCCredential.Status) {
        switch grpcCredentialStatus {
        case .unknown:
            self = .unknown
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
        case .disabled:
            self = .disabled
        case .awaitingThirdPartyAppAuthentication:
            self = .awaitingThirdPartyAppAuthentication
        case .sessionExpired:
            self = .sessionExpired
        case .UNRECOGNIZED(let value):
            assertionFailure("Unrecognized status:/ \(value)")
            self = .unknown
        }
    }
}

extension Credential.ThirdPartyAppAuthentication {
    init(grpcThirdPartyAppAuthentication: GRPCThirdPartyAppAuthentication) {
        self.downloadTitle = grpcThirdPartyAppAuthentication.downloadTitle
        self.downloadMessage = grpcThirdPartyAppAuthentication.downloadMessage
        self.upgradeTitle = grpcThirdPartyAppAuthentication.upgradeTitle
        self.upgradeMessage = grpcThirdPartyAppAuthentication.upgradeMessage
        if grpcThirdPartyAppAuthentication.hasIos {
            self.appStoreURL = URL(string: grpcThirdPartyAppAuthentication.ios.appStoreURL)
            self.scheme = grpcThirdPartyAppAuthentication.ios.scheme
            self.deepLinkURL = URL(string: grpcThirdPartyAppAuthentication.ios.deepLinkURL)
        } else {
            self.appStoreURL = nil
            self.scheme = nil
            self.deepLinkURL = nil
        }
    }
}
