import TinkLinkSDK

final class AuthorizationController {
    let tinkLink: TinkLink

    var user: User? {
        didSet {
            if let user = user {
                authorizationContext = AuthorizationContext(tinkLink: tinkLink, user: user)
                authorizationContext?.isAggregator { result in
                    self.isAggregator = try? result.get()
                    // TODO: Error handling
                    // Should flow be able to continue without this information?
                }
            } else {
                authorizationContext = nil
                isAggregator = nil
            }
        }
    }

    var isAggregator: Bool?

    private var authorizationContext: AuthorizationContext?

    init(tinkLink: TinkLink) {
        self.tinkLink = tinkLink
    }

    @discardableResult
    public func scopeDescriptions(scope: TinkLink.Scope, completion: @escaping (Result<[ScopeDescription], Error>) -> Void) -> RetryCancellable? {
        return authorizationContext?.scopeDescriptions(scope: scope, completion: completion)
    }
}
