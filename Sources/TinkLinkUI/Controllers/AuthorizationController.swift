import TinkLink

final class AuthorizationController {
    let tink: Tink

    var user: User? {
        didSet {
            if let user = user {
                authorizationContext = AuthorizationContext(tink: tink, user: user)
            } else {
                authorizationContext = nil
            }
        }
    }

    private var authorizationContext: AuthorizationContext?

    init(tink: Tink) {
        self.tink = tink
    }

    @discardableResult
    func authorize(scopes: [Scope], completion: @escaping (_ result: Result<AuthorizationCode, Error>) -> Void) -> RetryCancellable? {
        return authorizationContext?.authorize(scopes: scopes, completion: completion)
    }

    @discardableResult
    func clientDescription(completion: @escaping (Result<ClientDescription, Error>) -> Void) -> RetryCancellable? {
        return authorizationContext?.clientDescription(completion: completion)
    }

    @discardableResult
    public func scopeDescriptions(scopes: [Scope], completion: @escaping (Result<[ScopeDescription], Error>) -> Void) -> RetryCancellable? {
        guard let user = user else { return nil }
        return ConsentContext(tink: tink, user: user).scopeDescriptions(scopes: scopes, completion: completion)
    }
}
