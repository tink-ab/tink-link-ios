import TinkLink
import Foundation

extension Notification.Name {
    static let providerControllerWillFetchProviders = Notification.Name("providerControllerWillFetchProviders")
    static let providerControllerDidFetchProviders = Notification.Name("providerControllerDidFetchProviders")
    static let providerControllerDidFailWithError = Notification.Name("providerControllerDidFailWithError")
    static let providerControllerDidUpdateProviders = Notification.Name("ProviderControllerDidUpdateProviders")
}

final class ProviderController {

    enum Error: Swift.Error, LocalizedError {
        case emptyProviderList
        case missingInternetConnection

        init?(fetchProviderError error: Swift.Error) {
            switch error {
            case ServiceError.missingInternetConnection:
                self = .missingInternetConnection
            default:
                return nil
            }
        }
    }

    let tink: Tink
    
    private(set) var financialInstitutionGroupNodes: [ProviderTree.FinancialInstitutionGroupNode] = []
    private(set) var isFetching = false
    private(set) var error: Swift.Error?
    private var providers: [Provider] = []
    private var providerContext: ProviderContext?
    private var providerKinds: Set<Provider.Kind>

    init(tink: Tink, providerKinds: Set<Provider.Kind>) {
        self.tink = tink
        self.providerKinds = providerKinds
    }

    func performFetch() {
        guard !isFetching else { return }
        if providerContext == nil {
            providerContext = ProviderContext(tink: tink)
        }
        let attributes = ProviderContext.Attributes(capabilities: .all, kinds: providerKinds, accessTypes: .all)
        NotificationCenter.default.post(name: .providerControllerWillFetchProviders, object: self)
        isFetching = true
        tink._beginUITask()
        defer { tink._endUITask() }
        providerContext?.fetchProviders(attributes: attributes, completion: { [weak self] result in

            self?.isFetching = false
            do {
                let providers = try result.get()
                guard !providers.isEmpty else { throw Error.emptyProviderList }
                NotificationCenter.default.post(name: .providerControllerDidFetchProviders, object: self)
                let tree = ProviderTree(providers: providers)
                DispatchQueue.main.async {
                    self?.providers = providers
                    self?.financialInstitutionGroupNodes = tree.financialInstitutionGroups
                    NotificationCenter.default.post(name: .providerControllerDidUpdateProviders, object: self)
                }
            } catch {
                self?.error = Error(fetchProviderError: error) ?? error
                NotificationCenter.default.post(name: .providerControllerDidFailWithError, object: self)
            }
        })
    }

    func provider(providerID: Provider.ID) -> Provider? {
        return providers.first { $0.id == providerID }
    }
}
