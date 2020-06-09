import Foundation
#if os(iOS)
import UIKit
#endif

protocol URLResourceOpening {
    func open(_ url: URL, options: [UIApplication.OpenExternalURLOptionsKey : Any], completionHandler completion: ((Bool) -> Void)?)
}

extension UIApplication: URLResourceOpening {}
