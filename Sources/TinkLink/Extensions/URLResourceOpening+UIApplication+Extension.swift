import Foundation
#if os(iOS)
import UIKit
#endif

protocol URLResourceOpening {
    associatedtype URLResourceOpeningOptionKey: Hashable
    func open(_ url: URL, options: [URLResourceOpeningOptionKey: Any], completionHandler completion: ((Bool) -> Void)?)
    var universalLinksOnlyOptionKey: URLResourceOpeningOptionKey { get }
}

extension UIApplication: URLResourceOpening {
    var universalLinksOnlyOptionKey: UIApplication.OpenExternalURLOptionsKey { OpenExternalURLOptionsKey.universalLinksOnly }
}
