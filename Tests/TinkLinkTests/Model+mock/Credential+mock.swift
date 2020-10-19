import Foundation
@testable import TinkCore

extension Credentials {
    static let testPasswordCredentials = Credentials(
        id: Credentials.ID("test"),
        providerName: Provider.Name("test"),
        kind: .password,
        status: .created,
        statusPayload: "",
        statusUpdated: nil,
        updated: Date(),
        fields: [:],
        sessionExpiryDate: Date()
    )
}

extension Credentials {
    // Extension to update the status for test
    init(credentials: Credentials, status: Credentials.Status) {
        self = Credentials(id: credentials.id, providerName: credentials.providerName, kind: credentials.kind, status: status, statusPayload: credentials.statusPayload ?? "", statusUpdated: Date(), updated: Date(), fields: credentials.fields, sessionExpiryDate: credentials.sessionExpiryDate)
    }

    func nextCredentialsStatus() -> Credentials.Status {
        let nextStatus: Credentials.Status = {
            switch status {
            case .created, .authenticating:
                switch kind {
                case .mobileBankID:
                    return .awaitingMobileBankIDAuthentication(ThirdPartyAppAuthentication(downloadTitle: "Test download title", downloadMessage: "Test download message", upgradeTitle: "Test upgrade title", upgradeMessage: "Test upgrade message", appStoreURL: nil, scheme: "app", deepLinkURL: URL(string: "testApp://callback")))
                case .thirdPartyAuthentication:
                    return .awaitingThirdPartyAppAuthentication(ThirdPartyAppAuthentication(downloadTitle: "Test download title", downloadMessage: "Test download message", upgradeTitle: "Test upgrade title", upgradeMessage: "Test upgrade message", appStoreURL: nil, scheme: "app", deepLinkURL: URL(string: "testApp://callback")))
                case .password where self.providerName == "se-test-multi-supplemental":
                    return .awaitingSupplementalInformation([Provider.FieldSpecification(fieldDescription: "Code", hint: "", maxLength: nil, minLength: nil, isMasked: false, isNumeric: false, isImmutable: false, isOptional: false, name: "code", initialValue: "", pattern: "", patternError: "", helpText: "")])
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
        id: Credentials.ID = Credentials.ID(UUID().uuidString),
        providerName: Provider.Name,
        kind: Kind,
        status: Status,
        fields: [String: String] = [:]
    ) -> Credentials {
        return Credentials(
            id: id,
            providerName: providerName,
            kind: kind,
            status: status,
            statusPayload: "",
            statusUpdated: Date(),
            updated: Date(),
            fields: fields,
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
            providerName: providerName,
            kind: kind,
            status: status,
            statusPayload: statusPayload,
            statusUpdated: Date(),
            updated: updated,
            fields: fields,
            sessionExpiryDate: sessionExpiryDate
        )
    }

    mutating func modify(
        status: Status,
        statusPayload: String = ""
    ) {
        self = Credentials(
            id: id,
            providerName: providerName,
            kind: kind,
            status: status,
            statusPayload: statusPayload,
            statusUpdated: Date(),
            updated: updated,
            fields: fields,
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
            providerName: providerName,
            kind: kind,
            status: status,
            statusPayload: statusPayload,
            statusUpdated: Date(),
            updated: updated,
            fields: fields,
            sessionExpiryDate: sessionExpiryDate
        )
    }
}
