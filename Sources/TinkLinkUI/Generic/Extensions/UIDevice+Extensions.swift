import UIKit

extension UIDevice {
    var isPad: Bool {
        return userInterfaceIdiom == .pad
    }

    var isLandscape: Bool {
        return orientation != .portrait
    }
}
