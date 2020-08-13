import Foundation

public final class TinkLinkSessionManager: SessionManager {
    let authorizationContext: AuthorizationContext
    let consentContext: ConsentContext
    let credentialsContext: CredentialsContext
    let providerContext: ProviderContext
    let transferContext: TransferContext

    fileprivate var uiTaskCount = 0

    public init(tink: Tink = .shared) {
        authorizationContext = AuthorizationContext(tink: tink)
        consentContext = ConsentContext(tink: tink)
        credentialsContext = CredentialsContext(tink: tink)
        providerContext = ProviderContext(tink: tink)
        transferContext = TransferContext(tink: tink)
    }
}

extension Tink {
    private var tinkLinkSessionManager: TinkLinkSessionManager {
        var sessionManager: TinkLinkSessionManager
        if let tinkLinkSessionManager = sessionManagers.compactMap({ $0 as? TinkLinkSessionManager }).first {
            sessionManager = tinkLinkSessionManager
        } else {
            let tinkLinkSessionManager = TinkLinkSessionManager(tink: self)
            sessionManagers.append(tinkLinkSessionManager)
            sessionManager = tinkLinkSessionManager
        }
        return sessionManager
    }

    public var authorizationContext: AuthorizationContext {
        return tinkLinkSessionManager.authorizationContext
    }
    public var consentContext: ConsentContext {
        return tinkLinkSessionManager.consentContext
    }
    public var credentialsContext: CredentialsContext {
        return tinkLinkSessionManager.credentialsContext
    }
    public var providerContext: ProviderContext {
        return tinkLinkSessionManager.providerContext
    }
    public var transferContext: TransferContext {
        return tinkLinkSessionManager.transferContext
    }
}

extension Tink {
    public func _beginUITask() {
        tinkLinkSessionManager.uiTaskCount += 1
    }

    public func _endUITask() {
        tinkLinkSessionManager.uiTaskCount -= 1
    }
}
