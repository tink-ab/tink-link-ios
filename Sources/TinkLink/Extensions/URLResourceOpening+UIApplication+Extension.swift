import Foundation
#if os(iOS)
import UIKit
#endif

protocol URLResourceOpening {
    func open(_ url: URL, options: [String : Any], completionHandler completion: ((Bool) -> Void)?)
    var universalLinksOnlyOptionKey: String { get }
}

extension UIApplication: URLResourceOpening {}
