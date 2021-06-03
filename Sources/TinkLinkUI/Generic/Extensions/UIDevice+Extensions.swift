import UIKit

extension UIDevice {
    var isIpad: Bool {
        return UIDevice.current.userInterfaceIdiom == .pad
    }

    var isLandscape: Bool {
        return UIDevice.current.orientation != .portrait
    }
}
