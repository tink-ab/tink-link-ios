import Foundation
@testable import TinkLink
import XCTest

class AddBeneficiaryTaskTests: XCTestCase {
    var task: AddBeneficiaryTask?

    override func setUp() {
        try! Tink.configure(with: .init(clientID: "testID", redirectURI: URL(string: "app://callback")!))
    }

    func testSuccessfulAddBeneficiaryTask() {
    }
}
