import Foundation
@testable import TinkLink

extension Credentials {
    // Extension to update the status for test
    init(credentials: Credentials, status: Credentials.Status) {
        self = Credentials(id: credentials.id, providerID: credentials.providerID, kind: credentials.kind, status: status, statusPayload: credentials.statusPayload, statusUpdated: Date(), updated: Date(), fields: credentials.fields, supplementalInformationFields: credentials.supplementalInformationFields, thirdPartyAppAuthentication: credentials.thirdPartyAppAuthentication, sessionExpiryDate: credentials.sessionExpiryDate)
    }

    func nextCredentialsStatus() -> Credentials.Status {
        let nextStatus: Credentials.Status = {
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
