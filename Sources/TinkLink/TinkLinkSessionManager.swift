import TinkCore
import Foundation

public final class TinkLinkSessionManager: SessionManager {
    var queue: DispatchQueue

    let authorizationContext: AuthorizationContext
    let consentContext: ConsentContext
    let credentialsContext: CredentialsContext
    let providerContext: ProviderContext
    let transferContext: TransferContext

    public init(tink: Tink = .shared) {
        self.queue = DispatchQueue(label: "com.tink.TinkLink.SessionManager.queue", qos: .userInitiated)
        authorizationContext = AuthorizationContext(tink: tink)
        consentContext = ConsentContext(tink: tink)
        credentialsContext = CredentialsContext(tink: tink)
        providerContext = ProviderContext(tink: tink)
        transferContext = TransferContext(tink: tink)

    }
}

extension Tink {
    public var authorizationContext: AuthorizationContext? {
        return sessionManagers.compactMap {
            $0 as? TinkLinkSessionManager
        }.first?.authorizationContext
    }
    public var consentContext: ConsentContext? {
        return sessionManagers.compactMap {
            $0 as? TinkLinkSessionManager
        }.first?.consentContext
    }
    public var credentialsContext: CredentialsContext? {
        return sessionManagers.compactMap {
            $0 as? TinkLinkSessionManager
        }.first?.credentialsContext
    }
    public var providerContext: ProviderContext? {
        return sessionManagers.compactMap {
            $0 as? TinkLinkSessionManager
        }.first?.providerContext
    }
    public var transferContext: TransferContext? {
        return sessionManagers.compactMap {
            $0 as? TinkLinkSessionManager
        }.first?.transferContext
    }
}
