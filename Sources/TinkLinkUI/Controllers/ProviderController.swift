import TinkLinkSDK
import Foundation

extension Notification.Name {
    static let providerControllerWillFetchProviders = Notification.Name("providerControllerWillFetchProviders")
    static let providerControllerDidFetchProviders = Notification.Name("providerControllerDidFetchProviders")
    static let providerControllerDidUpdateProviders = Notification.Name("ProviderControllerDidUpdateProviders")
}

final class ProviderController {
    let tinkLink: TinkLink
    
    var financialInstitutionNodes: [ProviderTree.FinancialInstitutionNode] {
        return ProviderTree(providers: providers).makeFinancialInstitutions()
    }
    
    var user: User? {
        didSet {
            if user != nil {
                performFetch()
            }
        }
    }

    private(set) var financialInstitutionGroupNodes: [ProviderTree.FinancialInstitutionGroupNode] = []
    private(set) var isFetching = false
    private var providers: [Provider] = []
    private var providerContext: ProviderContext?

    init(tinkLink: TinkLink) {
        self.tinkLink = tinkLink
    }

    func performFetch() {
        guard let user = user else { return }
        if providerContext == nil {
            providerContext = ProviderContext(tinkLink: tinkLink, user: user)
        }
        let attributes = ProviderContext.Attributes(capabilities: .all, kinds: .all, accessTypes: .all)
        NotificationCenter.default.post(name: .providerControllerWillFetchProviders, object: self)
        isFetching = true
        providerContext?.fetchProviders(attributes: attributes, completion: { [weak self] result in
            self?.isFetching = false
            NotificationCenter.default.post(name: .providerControllerDidFetchProviders, object: self)
            do {
                let providers = try result.get()
                let tree = ProviderTree(providers: providers)
                DispatchQueue.main.async {
                    self?.providers = providers
                    self?.financialInstitutionGroupNodes = tree.financialInstitutionGroups
                    NotificationCenter.default.post(name: .providerControllerDidUpdateProviders, object: self)
                }
            } catch {
                // Handle any errors
            }
        })
    }

    func provider(providerID: Provider.ID) -> Provider? {
        return providers.first { $0.id == providerID }
    }
}
