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
        case providerNotFound
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

    func fetch(with providerPredicate: TinkLinkViewController.ProviderPredicate, for market: Market? = nil, completion: ((Result<[Provider], Swift.Error>) -> Void)? = nil) {
        guard !isFetching else { return }
        isFetching = true
        NotificationCenter.default.post(name: .providerControllerWillFetchProviders, object: self)

        switch providerPredicate.value {
        case .name(let id):
            fetchProvider(with: id, for: market) { result in
                do {
                    let provider = try result.get()
                    completion?(.success([provider]))
                } catch {
                    completion?(.failure(error))
                }
            }
        case .kinds(let kinds):
            fetchProviders(kinds: kinds, for: market, completion: completion)
        }
    }

    private func fetchProviders(kinds: Set<Provider.Kind>, for market: Market?, completion: ((Result<[Provider], Swift.Error>) -> Void)?) {
        tink._beginUITask()
        defer { tink._endUITask() }

        let filter = ProviderContext.Filter(capabilities: .all, kinds: kinds, accessTypes: .all)
        providerContext.fetchProviders(for: market, filter: filter) { [weak self] result in
            self?.isFetching = false
            do {
                let providers = try result.get().filter { $0.status == .enabled }
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
                self?.error = error
                completion?(.failure(error))
                NotificationCenter.default.post(name: .providerControllerDidFailWithError, object: self)
            }
        }
    }

    func fetchProvider(with name: Provider.Name, for market: Market?, completion: @escaping ((Result<Provider, Swift.Error>) -> Void)) {
        tink._beginUITask()
        defer { tink._endUITask() }

        if let market = market {
            let filter = ProviderContext.Filter(capabilities: .all, kinds: .all, accessTypes: .all)
            providerContext.fetchProviders(for: market, filter: filter) { [weak self] result in
                self?.isFetching = false
                do {
                    let fetchedProviders = try result.get()
                    if let provider = fetchedProviders.first(where: { $0.id == name }) {
                        DispatchQueue.main.async {
                            completion(.success(provider))
                        }
                    } else {
                        completion(.failure(Error.providerNotFound))
                    }
                } catch {
                    self?.error = error
                    completion(.failure(error))
                }
            }
        } else {
            providerContext.fetchProvider(with: name, completion: { [weak self] result in
                self?.isFetching = false
                do {
                    let provider = try result.get()
                    DispatchQueue.main.async {
                        completion(Result.success(provider))
                    }
                } catch ServiceError.notFound {
                    completion(.failure(Error.providerNotFound))
                } catch {
                    self?.error = error
                    completion(.failure(error))
                }
            })
        }
    }

    func provider(providerName: Provider.Name) -> Provider? {
        return providers.first { $0.name == providerName }
    }
}

extension ProviderContext {
    @discardableResult
    fileprivate func fetchProviders(for market: Market?, filter: Filter, completion: @escaping (Result<[Provider], Error>) -> Void) -> RetryCancellable? {
        if let market = market {
            return fetchProviders(for: market, filter: filter, completion: completion)
        } else {
            return fetchProviders(filter: filter, completion: completion)
        }
    }
}
