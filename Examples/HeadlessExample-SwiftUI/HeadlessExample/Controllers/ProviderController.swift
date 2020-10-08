import TinkLink
import SwiftUI

final class ProviderController: ObservableObject {
    @Published var providers: [Provider] = []

    private var providerContext = Tink.shared.providerContext

    func performFetch() {
        providerContext.fetchProviders { [weak self] result in
            do {
                let providers = try result.get()
                DispatchQueue.main.async {
                    self?.providers = providers
                }
            } catch {
                // Handle any errors
            }
        }
    }

    func provider(providerID: Provider.ID) -> Provider? {
        return providers.first { $0.id == providerID }
    }
}
