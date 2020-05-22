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
    private lazy var providerContext = ProviderContext(tink: tink)

    init(tink: Tink) {
        self.tink = tink
    }

    func fetch(with providerPredicate: TinkLinkViewController.ProviderPredicate, completion: ((Result<[Provider], Swift.Error>) -> Void)? = nil) {
        guard !isFetching else { return }
        isFetching = true
        NotificationCenter.default.post(name: .providerControllerWillFetchProviders, object: self)

        switch providerPredicate {
        case .name(let id):
            fetchProvider(with: id) { result in
                do {
                    let provider = try result.get()
                    completion?(.success([provider]))
                } catch {
                    completion?(.failure(error))
                }
            }
        case .kinds(let kinds):
            fetchProviders(kinds: kinds, completion: completion)
        }
    }

    private func fetchProviders(kinds: Set<Provider.Kind>, completion: ((Result<[Provider], Swift.Error>) -> Void)? = nil) {
        tink._beginUITask()
        defer { tink._endUITask() }

        let attributes = ProviderContext.Attributes(capabilities: .all, kinds: kinds, accessTypes: .all)
        providerContext.fetchProviders(attributes: attributes, completion: { [weak self] result in

            self?.isFetching = false
            do {
                let providers = try result.get()
                guard !providers.isEmpty else { throw Error.emptyProviderList }
                NotificationCenter.default.post(name: .providerControllerDidFetchProviders, object: self)
                let tree = ProviderTree(providers: providers)
                DispatchQueue.main.async {
                    self?.providers = providers
                    self?.financialInstitutionGroupNodes = tree.financialInstitutionGroups
                    completion?(.success(providers))
                    NotificationCenter.default.post(name: .providerControllerDidUpdateProviders, object: self)
                }
            } catch {
                self?.error = Error(fetchProviderError: error) ?? error
                completion?(.failure(Error(fetchProviderError: error) ?? error))
                NotificationCenter.default.post(name: .providerControllerDidFailWithError, object: self)
            }
        })
    }

    func fetchProvider(with id: Provider.ID, completion: @escaping ((Result<Provider, Swift.Error>) -> Void)) {
        tink._beginUITask()
        defer { tink._endUITask() }

        providerContext.fetchProvider(with: id, completion: { [weak self] result in

            self?.isFetching = false
            do {
                let provider = try result.get()
                DispatchQueue.main.async {
                    completion(Result.success(provider))
                }
            } catch {
                self?.error = Error(fetchProviderError: error) ?? error
                completion(.failure(Error(fetchProviderError: error) ?? error))
            }
        })
    }

    func provider(providerID: Provider.ID) -> Provider? {
        return providers.first { $0.id == providerID }
    }
}
