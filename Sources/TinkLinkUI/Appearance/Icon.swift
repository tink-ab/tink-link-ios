import UIKit

enum Icon {
    case bankID
    case password
    case profile
    case warning

    var name: String {
        switch self {
        case .bankID:
            return "bankID"
        case .password:
            return "password"
        case .profile:
            return "profile"
        case .warning:
            return "warning"
        }
    }
}

extension UIImage {
    convenience init?(icon: Icon) {
        self.init(named: icon.name, in: .assetBundle, compatibleWith: nil)
    }
}
