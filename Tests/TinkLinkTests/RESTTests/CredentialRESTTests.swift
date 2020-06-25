@testable import TinkLink
import XCTest

class CredentialRESTTests: XCTestCase {
    func testCreatedCapabilitiesMapping() {
        let restCredentials = RESTCredentials(
            id: "6e68cc6287704273984567b3300c5822",
            providerName: "handelsbanken-bankid",
            type: .mobileBankid,
            status: .created,
            statusUpdated: nil,
            statusPayload: "Analyzed 1,200 out of 1,200 transactions",
            updated: nil,
            fields: ["username": "180012121234"],
            supplementalInformation: nil,
            sessionExpiryDate: nil,
            userId: nil
        )

        let credential = Credentials(restCredentials: restCredentials)

        XCTAssertEqual(credential.id.value, restCredentials.id)
        XCTAssertEqual(credential.providerID.value, restCredentials.providerName)
        XCTAssertEqual(credential.kind, .mobileBankID)
        XCTAssertEqual(credential.status, .created)
        XCTAssertEqual(credential.statusPayload, restCredentials.statusPayload)
        XCTAssertNil(credential.updated)
        XCTAssertEqual(credential.fields, restCredentials.fields)
        XCTAssertTrue(credential.supplementalInformationFields.isEmpty)
        XCTAssertNil(credential.thirdPartyAppAuthentication)
        XCTAssertNil(credential.sessionExpiryDate)
    }

    func testUpdatedCredentialMapping() {
        let updatedAt = Calendar.current.date(from: DateComponents(year: 2019, month: 10, day: 8, hour: 15, minute: 24))!

        let restCredentials = RESTCredentials(
            id: "6e68cc6287704273984567b3300c5822",
            providerName: "handelsbanken-bankid",
            type: .mobileBankid,
            status: .updated,
            statusUpdated: nil,
            statusPayload: "Analyzed 1,200 out of 1,200 transactions",
            updated: updatedAt,
            fields: ["username": "180012121234"],
            supplementalInformation: nil,
            sessionExpiryDate: nil,
            userId: nil
        )

        let credential = Credentials(restCredentials: restCredentials)

        XCTAssertEqual(credential.id.value, restCredentials.id)
        XCTAssertEqual(credential.providerID.value, restCredentials.providerName)
        XCTAssertEqual(credential.kind, .mobileBankID)
        XCTAssertEqual(credential.status, .updated)
        XCTAssertEqual(credential.statusPayload, restCredentials.statusPayload)
        XCTAssertEqual(credential.updated, updatedAt)
        XCTAssertEqual(credential.fields, restCredentials.fields)
        XCTAssertTrue(credential.supplementalInformationFields.isEmpty)
        XCTAssertNil(credential.thirdPartyAppAuthentication)
        XCTAssertNil(credential.sessionExpiryDate)
    }

    func testAwaitingThirdPartyAppAuthenticationCredentialMapping() {
        let restCredentials = RESTCredentials(
            id: "6e68cc6287704273984567b3300c5822",
            providerName: "handelsbanken-bankid",
            type: .thirdPartyApp,
            status: .awaitingThirdPartyAppAuthentication,
            statusUpdated: nil,
            statusPayload: "Analyzed 1,200 out of 1,200 transactions",
            updated: nil,
            fields: ["username": "180012121234"],
            supplementalInformation: "{\"android\":{\"packageName\":\"this.is.not.a.valid.package.name\",\"requiredMinimumVersion\":0,\"intent\":\"this.is.not.a.valid.intent\"},\"ios\":{\"appStoreUrl\":\"https://itunes.apple.com\",\"scheme\":\"this.is.not.a.valid.app.scheme\",\"deepLinkUrl\":\"this.is.not.a.valid.deeplink\"},\"desktop\":{\"url\":\"https://test.com\"},\"downloadTitle\":\"Download Tink Demo Authentication app\",\"downloadMessage\":\"You need to download the Tink Demo Authentication app in order to continue.\",\"upgradeTitle\":\"Upgrade Tink Demo Authentication app\",\"upgradeMessage\":\"You need to upgrade the Tink Demo Authentication app in order to continue.\"}",
            sessionExpiryDate: nil,
            userId: nil
        )

        let credential = Credentials(restCredentials: restCredentials)

        XCTAssertEqual(credential.id.value, restCredentials.id)
        XCTAssertEqual(credential.providerID.value, restCredentials.providerName)
        XCTAssertEqual(credential.kind, .thirdPartyAuthentication)
        XCTAssertEqual(credential.status, .awaitingThirdPartyAppAuthentication)
        XCTAssertEqual(credential.statusPayload, restCredentials.statusPayload)
        XCTAssertNil(credential.updated)
        XCTAssertEqual(credential.fields, restCredentials.fields)
        XCTAssertTrue(credential.supplementalInformationFields.isEmpty)
        XCTAssertNotNil(credential.thirdPartyAppAuthentication)

        XCTAssertEqual(credential.thirdPartyAppAuthentication?.deepLinkURL?.absoluteString, "this.is.not.a.valid.deeplink")
        XCTAssertEqual(credential.thirdPartyAppAuthentication?.appStoreURL?.absoluteString, "https://itunes.apple.com")
        XCTAssertEqual(credential.thirdPartyAppAuthentication?.scheme, "this.is.not.a.valid.app.scheme")
        XCTAssertEqual(credential.thirdPartyAppAuthentication?.downloadTitle, "Download Tink Demo Authentication app")
        XCTAssertEqual(credential.thirdPartyAppAuthentication?.downloadMessage, "You need to download the Tink Demo Authentication app in order to continue.")
        XCTAssertEqual(credential.thirdPartyAppAuthentication?.upgradeTitle, "Upgrade Tink Demo Authentication app")
        XCTAssertEqual(credential.thirdPartyAppAuthentication?.upgradeMessage, "You need to upgrade the Tink Demo Authentication app in order to continue.")

        XCTAssertNil(credential.sessionExpiryDate)
    }

    func testAwaitingBankIDCredentialMapping() {
        let restCredentials = RESTCredentials(
            id: "6e68cc6287704273984567b3300c5822",
            providerName: "handelsbanken-bankid",
            type: .mobileBankid,
            status: .awaitingMobileBankidAuthentication,
            statusUpdated: nil,
            statusPayload: "Analyzed 1,200 out of 1,200 transactions",
            updated: nil,
            fields: ["username": "180012121234"],
            supplementalInformation: "TOKEN",
            sessionExpiryDate: nil,
            userId: nil
        )

        let credential = Credentials(restCredentials: restCredentials)

        XCTAssertEqual(credential.id.value, restCredentials.id)
        XCTAssertEqual(credential.providerID.value, restCredentials.providerName)
        XCTAssertEqual(credential.kind, .mobileBankID)
        XCTAssertEqual(credential.status, .awaitingMobileBankIDAuthentication)
        XCTAssertEqual(credential.statusPayload, restCredentials.statusPayload)
        XCTAssertNil(credential.updated)
        XCTAssertEqual(credential.fields, restCredentials.fields)
        XCTAssertTrue(credential.supplementalInformationFields.isEmpty)
        XCTAssertNotNil(credential.thirdPartyAppAuthentication)

        XCTAssertEqual(credential.thirdPartyAppAuthentication?.deepLinkURL?.absoluteString, "bankid:///?autostartToken=TOKEN&redirect=tink://bankid/credentials/6e68cc6287704273984567b3300c5822")
        XCTAssertEqual(credential.thirdPartyAppAuthentication?.appStoreURL?.absoluteString, "itms://itunes.apple.com/se/app/bankid-sakerhetsapp/id433151512")

        XCTAssertNil(credential.sessionExpiryDate)
    }
}
