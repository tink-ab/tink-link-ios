import TinkLinkSDK
import SwiftUI

final class ProviderController: ObservableObject {
    @Published var providers: [Provider] = []
    var user: User? {
        didSet {
            if user != nil {
                performFetch()
            }
        }
    }
    
    private var providerContext: ProviderContext?

    func performFetch() {
        guard let user = user else { return }
        if providerContext == nil {
            providerContext = ProviderContext(user: user)
        }
        let attributes = ProviderContext.Attributes(capabilities: .all, kinds: .all, accessTypes: .all)
        providerContext?.fetchProviders(attributes: attributes, completion: { [weak self] result in
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
