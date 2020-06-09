import Foundation

@testable import TinkLink

struct MockedSuccessOpeningApplication: URLResourceOpening {
    func open(_ url: URL, options: [String : Any], completionHandler completion: ((Bool) -> Void)?) {
        completion?(true)
    }

    var universalLinksOnlyOptionKey: String = "Test"
}

extension ThirdPartyAppAuthenticationTask {
    func handle<URLResourceOpener: URLResourceOpening>(with application: URLResourceOpener, completion: @escaping (Result<Void, Swift.Error>) -> Void) {
        openThirdPartyApp(with: application) { [weak self] result in
            self?.completionHandler(result)
            completion(result)
        }
    }
}
