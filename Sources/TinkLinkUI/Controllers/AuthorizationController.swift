import TinkLinkSDK

final class AuthorizationController {
    let tinkLink: TinkLink

    var user: User? {
        didSet {
            if let user = user {
                authorizationContext = AuthorizationContext(tinkLink: tinkLink, user: user)
            } else {
                authorizationContext = nil
            }
        }
    }

    private var authorizationContext: AuthorizationContext?

    init(tinkLink: TinkLink) {
        self.tinkLink = tinkLink
    }

    @discardableResult
    func isAggregator(completion: @escaping (Result<Bool, Error>) -> Void) -> RetryCancellable? {
        return authorizationContext?.isAggregator(completion: completion)
    }

    @discardableResult
    public func scopeDescriptions(scope: TinkLink.Scope, completion: @escaping (Result<[ScopeDescription], Error>) -> Void) -> RetryCancellable? {
        return authorizationContext?.scopeDescriptions(scope: scope, completion: completion)
    }
}
