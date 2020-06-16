import XCTest
@testable import TinkLink

class MultiCancellerTests: XCTestCase {
    func testCancellingOneCanceller() {
        let multiCanceller = MultiCanceller()

        var isExecuted = false
        let work = DispatchWorkItem {
            isExecuted = true
        }

        XCTAssertFalse(isExecuted)
        XCTAssertFalse(work.isCancelled)

        multiCanceller.add(work)

        multiCanceller.cancel()

        work.perform()

        XCTAssertTrue(work.isCancelled)
        XCTAssertFalse(isExecuted)
    }

    func testCancellingTwoCancellers() {
        let multiCanceller = MultiCanceller()

        var isWorkAExecuted = false
        var isWorkBExecuted = false

        let workA = DispatchWorkItem {
            isWorkAExecuted = true
        }
        let workB = DispatchWorkItem {
            isWorkBExecuted = true
        }

        XCTAssertFalse(isWorkAExecuted)
        XCTAssertFalse(isWorkBExecuted)
        XCTAssertFalse(workA.isCancelled)
        XCTAssertFalse(workB.isCancelled)

        multiCanceller.add(workA)
        multiCanceller.add(workB)

        multiCanceller.cancel()

        workA.perform()
        workB.perform()

        XCTAssertTrue(workA.isCancelled)
        XCTAssertTrue(workB.isCancelled)
        XCTAssertFalse(isWorkAExecuted)
        XCTAssertFalse(isWorkBExecuted)
    }
}
