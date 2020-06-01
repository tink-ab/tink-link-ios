import Foundation
@testable import TinkLink
import XCTest

class TransferRESTTest: XCTestCase {
    func testSignableOperationMapping() {
        let restSignableOperation = RESTSignableOperation(
            created: Date(),
            credentialsId: "8b17841deb9445e5bf3640bf20426ea5",
            id: "2dd35cc09f2e11eab6339f71b1190a65",
            status: .created,
            statusMessage: nil,
            type: .transfer,
            underlyingId: "d098262a0d7740b5ae1afe6e52a4a343",
            updated: Date(),
            userId: "64b63e21d8ce4c60b240bbd35471de5e"
        )

        let signableOperation = SignableOperation(restSignableOperation)
        XCTAssertEqual(signableOperation.credentialsID?.value, restSignableOperation.credentialsId)
        XCTAssertEqual(signableOperation.id?.value, restSignableOperation.id)
        XCTAssertEqual(signableOperation.transferID?.value, restSignableOperation.underlyingId)
        XCTAssertEqual(signableOperation.userID?.value, restSignableOperation.userId)
        XCTAssertEqual(signableOperation.status, restSignableOperation.status.flatMap { SignableOperation.Status($0) })
    }
}
