import Foundation
import TinkCore

extension Credentials {
    // Extension to update the status for test
    init(credentials: Credentials, status: Credentials.Status) {
        var supplementalInformationFields = [Provider.FieldSpecification]()
        var thirdPartyAppAuthentication: ThirdPartyAppAuthentication?
        switch status {
        case .awaitingSupplementalInformation:
            supplementalInformationFields = [Provider.FieldSpecification(fieldDescription: "Code", hint: "", maxLength: nil, minLength: nil, isMasked: false, isNumeric: false, isImmutable: false, isOptional: false, name: "code", initialValue: "", pattern: "", patternError: "", helpText: "")]
        case .awaitingMobileBankIDAuthentication, .awaitingThirdPartyAppAuthentication:
            thirdPartyAppAuthentication = ThirdPartyAppAuthentication(downloadTitle: "Test download title", downloadMessage: "Test download message", upgradeTitle: "Test upgrade title", upgradeMessage: "Test upgrade message", appStoreURL: nil, scheme: "app", deepLinkURL: URL(string: "testApp://callback"))
        default:
            break
        }
        self = Credentials(id: credentials.id, providerID: credentials.providerID, kind: credentials.kind, status: status, statusPayload: credentials.statusPayload, statusUpdated: Date(), updated: Date(), fields: credentials.fields, supplementalInformationFields: supplementalInformationFields, thirdPartyAppAuthentication: thirdPartyAppAuthentication, sessionExpiryDate: credentials.sessionExpiryDate)
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
                case .password where self.providerID == "se-test-multi-supplemental":
                    return .awaitingSupplementalInformation
                default:
                    return .updating
                }
            case .awaitingMobileBankIDAuthentication,
                 .awaitingThirdPartyAppAuthentication,
                 .awaitingSupplementalInformation:
                return .updating
            case .updating:
                return .updated
            default:
                return .updated
            }
        }()
        return nextStatus
    }

    static func makeTestCredentials(
        providerID: Provider.ID,
        kind: Kind,
        status: Status,
        fields: [String: String] = [:]
    ) -> Credentials {
        return Credentials(
            id: Credentials.ID(UUID().uuidString),
            providerID: providerID,
            kind: kind,
            status: status,
            statusPayload: "",
            statusUpdated: Date(),
            updated: Date(),
            fields: fields,
            supplementalInformationFields: [],
            thirdPartyAppAuthentication: nil,
            sessionExpiryDate: nil
        )
    }

    mutating func modify(
        fields: [String: String],
        status: Status,
        statusPayload: String = ""
    ) {
        self = Credentials(
            id: id,
            providerID: providerID,
            kind: kind,
            status: status,
            statusPayload: statusPayload,
            statusUpdated: Date(),
            updated: updated,
            fields: fields,
            supplementalInformationFields: supplementalInformationFields,
            thirdPartyAppAuthentication: thirdPartyAppAuthentication,
            sessionExpiryDate: sessionExpiryDate
        )
    }

    mutating func modify(
        supplementalInformationFields: [Provider.FieldSpecification],
        status: Status,
        statusPayload: String = ""
    ) {
        self = Credentials(
            id: id,
            providerID: providerID,
            kind: kind,
            status: status,
            statusPayload: statusPayload,
            statusUpdated: Date(),
            updated: updated,
            fields: fields,
            supplementalInformationFields: supplementalInformationFields,
            thirdPartyAppAuthentication: thirdPartyAppAuthentication,
            sessionExpiryDate: sessionExpiryDate
        )
    }

    mutating func modify(
        thirdPartyAppAuthentication: ThirdPartyAppAuthentication?,
        status: Status,
        statusPayload: String = ""
    ) {
        self = Credentials(
            id: id,
            providerID: providerID,
            kind: kind,
            status: status,
            statusPayload: statusPayload,
            statusUpdated: Date(),
            updated: updated,
            fields: fields,
            supplementalInformationFields: supplementalInformationFields,
            thirdPartyAppAuthentication: thirdPartyAppAuthentication,
            sessionExpiryDate: sessionExpiryDate
        )
    }
}
