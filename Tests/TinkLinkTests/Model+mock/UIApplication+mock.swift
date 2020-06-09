import Foundation
#if os(iOS)
import UIKit
#endif
@testable import TinkLink

struct MockApplication: URLResourceOpening {
    func open(_ url: URL, options: [UIApplication.OpenExternalURLOptionsKey : Any], completionHandler completion: ((Bool) -> Void)?) {
        completion?(true)
    }
}

extension ThirdPartyAppAuthenticationTask {
    func handle(with application: URLResourceOpening, completion: @escaping (Result<Void, Swift.Error>) -> Void) {
        openThirdPartyApp(with: application) { [weak self] result in
            self?.completionHandler(result)
            completion(result)
        }
    }
}
