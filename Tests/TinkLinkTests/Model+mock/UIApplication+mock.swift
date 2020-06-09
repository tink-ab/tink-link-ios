import Foundation

@testable import TinkLink

struct MockApplication: URLResourceOpening {
    func open(_ url: URL, options: [String : Any], completionHandler completion: ((Bool) -> Void)?) {
        completion?(true)
    }

    var universalLinksOnlyOptionKey: String = "Test"
}

extension ThirdPartyAppAuthenticationTask {
    func handle(with application: URLResourceOpening, completion: @escaping (Result<Void, Swift.Error>) -> Void) {
        openThirdPartyApp(with: application) { [weak self] result in
            self?.completionHandler(result)
            completion(result)
        }
    }
}
