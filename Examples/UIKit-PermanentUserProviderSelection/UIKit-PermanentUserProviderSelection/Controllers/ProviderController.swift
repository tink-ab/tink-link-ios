import TinkLink
import Foundation

extension Notification.Name {
    static let providerControllerDidUpdateProviders = Notification.Name("ProviderControllerDidUpdateProviders")
}

final class ProviderController {
    var providers: [Provider] = [] {
        didSet {
            NotificationCenter.default.post(name: .providerControllerDidUpdateProviders, object: nil)
        }
    }
    var financialInstitutionGroupNodes: [ProviderTree.FinancialInstitutionGroupNode] {
        return ProviderTree(providers: providers).financialInstitutionGroups
    }
    var user: User? {
        didSet {
            if user != nil {
                performFetch()
            }
        }
    }
    
    private var providerContext = ProviderContext()

    func performFetch() {
        let attributes = ProviderContext.Attributes(capabilities: .all, kinds: .all, accessTypes: .all)
        providerContext.fetchProviders(attributes: attributes, completion: { [weak self] result in
            do {
                let providers = try result.get()
                DispatchQueue.main.async {
                    self?.providers = providers
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
