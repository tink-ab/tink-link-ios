import Foundation

extension ProcessInfo {
    var tinkEnableBankIDOnAnotherDevice: Bool {
        return environment["TINK_BANKID_ANOTHER_DEVICE"] == "YES"
    }
}
