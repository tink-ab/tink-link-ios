import Foundation
#if os(iOS)
import UIKit
#endif

protocol URLResourceOpening {
    func open(_ url: URL, options: [String : Any], completionHandler completion: ((Bool) -> Void)?)
    var universalLinksOnlyOptionKey: String { get }
}

extension UIApplication: URLResourceOpening {
    func open(_ url: URL, options: [String : Any], completionHandler completion: ((Bool) -> Void)?) {
        let mappedOptions = options.map { (key, value) in
            return (OpenExternalURLOptionsKey(rawValue: key), value)
        }
        let dictionary = Dictionary.init(uniqueKeysWithValues: mappedOptions)
        open(url, options: dictionary, completionHandler: completion)
    }

    var universalLinksOnlyOptionKey: String { OpenExternalURLOptionsKey.universalLinksOnly.rawValue }
}
