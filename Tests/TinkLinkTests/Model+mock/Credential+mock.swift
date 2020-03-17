import Foundation
@testable import TinkLink

extension Credential {
    // Extension to update the status for test
    init(credential: Credential, status: Credential.Status) {
        self = Credential(id: credential.id, providerID: credential.providerID, kind: credential.kind, status: status, statusPayload: credential.statusPayload, statusUpdated: Date(), updated: Date(), fields: credential.fields, supplementalInformationFields: credential.supplementalInformationFields, thirdPartyAppAuthentication: credential.thirdPartyAppAuthentication, sessionExpiryDate: credential.sessionExpiryDate)
    }

    func nextCredentialStatus() -> Credential.Status {
        let nextStatus: Credential.Status = {
            switch status {
            case .created, .authenticating:
                switch kind {
                case .mobileBankID:
                    return .awaitingMobileBankIDAuthentication
                case .thirdPartyAuthentication:
                    return .awaitingThirdPartyAppAuthentication
                default:
                    return .updating
                }
            case .awaitingMobileBankIDAuthentication, .awaitingThirdPartyAppAuthentication:
                return .updating
            case .updating:
                return .updated
            default:
                return .updated
            }
        }()
        return nextStatus
    }
}
