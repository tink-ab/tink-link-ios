import UIKit

enum Icon {
    case bankID
    case business
    case corporate
    case password
    case profile
    case warning
    case tink

    fileprivate var name: String {
        switch self {
        case .bankID:
            return "bankID"
        case .business:
            return "business"
        case .corporate:
            return "corporate"
        case .password:
            return "password"
        case .profile:
            return "profile"
        case .warning:
            return "warning"
        case .tink:
            return "tink"
        }
    }
}

extension UIImage {
    convenience init?(icon: Icon) {
        self.init(named: icon.name, in: .assetBundle, compatibleWith: nil)
    }
}
