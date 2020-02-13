import TinkLinkSDK

final class AuthorizationController {
    var user: User? {
        didSet {
            if let user = user {
                authorizationContext = AuthorizationContext(user: user)
            } else {
                authorizationContext = nil
            }
        }
    }

    private var authorizationContext: AuthorizationContext?

    @discardableResult
    public func scopeDescriptions(scope: TinkLink.Scope, completion: @escaping (Result<[ScopeDescription], Error>) -> Void) -> RetryCancellable? {
        return authorizationContext?.scopeDescriptions(scope: scope, completion: completion)
    }
}
