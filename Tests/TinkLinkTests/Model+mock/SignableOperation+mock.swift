import Foundation
@testable import TinkLink
import XCTest

extension SignableOperation {
    static let createdSignableOperation = SignableOperation(
        created: Date(),
        credentialsID: Credentials.ID("8b17841deb9445e5bf3640bf20426ea5"),
        id: ID("2dd35cc09f2e11eab6339f71b1190a65"),
        status: .created,
        statusMessage: nil,
        kind: .transfer,
        transferID: Transfer.ID("d098262a0d7740b5ae1afe6e52a4a343"),
        updated: Date(),
        userID: User.ID("64b63e21d8ce4c60b240bbd35471de5e")
    )

    static let awaitingCredentialsSignableOperation = SignableOperation(
        created: Date(),
        credentialsID: Credentials.ID("8b17841deb9445e5bf3640bf20426ea5"),
        id: ID("2dd35cc09f2e11eab6339f71b1190a65"),
        status: .awaitingCredentials,
        statusMessage: nil,
        kind: .transfer,
        transferID: Transfer.ID("d098262a0d7740b5ae1afe6e52a4a343"),
        updated: Date(),
        userID: User.ID("64b63e21d8ce4c60b240bbd35471de5e")
    )

    static let executedSignableOperation = SignableOperation(
        created: Date(),
        credentialsID: Credentials.ID("8b17841deb9445e5bf3640bf20426ea5"),
        id: ID("2dd35cc09f2e11eab6339f71b1190a65"),
        status: .executed,
        statusMessage: "Le transfert a été envoyé à votre banque.",
        kind: .transfer,
        transferID: Transfer.ID("d098262a0d7740b5ae1afe6e52a4a343"),
        updated: Date(),
        userID: User.ID("64b63e21d8ce4c60b240bbd35471de5e")
    )

    static let cancelledSignableOperation = SignableOperation(
        created: Date(),
        credentialsID: Credentials.ID("8b17841deb9445e5bf3640bf20426ea5"),
        id: ID("500b78a09f5f11eaabc717c82c665497"),
        status: .cancelled,
        statusMessage: "Cancel on payment signing (test)",
        kind: .transfer,
        transferID: Transfer.ID("ff3de94f21a54701be12f481de760eb1"),
        updated: Date(),
        userID: User.ID("64b63e21d8ce4c60b240bbd35471de5e")
}
