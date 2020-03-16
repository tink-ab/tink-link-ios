import GRPC
import Dispatch

protocol ProviderService {
    func providers(market: Market?, capabilities: Provider.Capabilities, includeTestProviders: Bool, completion: @escaping (Result<[Provider], Error>) -> Void) -> RetryCancellable?
}

final class TinkProviderService: ProviderService, TokenConfigurableService {
    let connection: ClientConnection
    var defaultCallOptions: CallOptions {
        didSet {
            service.defaultCallOptions = defaultCallOptions
        }
    }
    private let queue: DispatchQueue

    var accessToken: AccessToken? {
        didSet {
            if let accessToken = accessToken {
                defaultCallOptions.addAccessToken(accessToken.rawValue)
            }
        }
    }

    convenience init(tink: Tink = .shared, accessToken: AccessToken? = nil) {
        var defaultCallOptions = tink.client.defaultCallOptions
        if let accessToken = accessToken {
            defaultCallOptions.addAccessToken(accessToken.rawValue)
        }
        self.init(connection: tink.client.connection, defaultCallOptions: defaultCallOptions, queue: tink.client.queue)
        self.accessToken = accessToken
    }

    init(connection: ClientConnection, defaultCallOptions: CallOptions, queue: DispatchQueue) {
        self.connection = connection
        self.defaultCallOptions = defaultCallOptions
        self.queue = queue
    }

    internal lazy var service = ProviderServiceServiceClient(connection: connection, defaultCallOptions: defaultCallOptions)

    /// Lists all providers
    ///
    /// - Parameters:
    ///   - market: The market to fetch providers for. If no market is specified the providers for the users current market will be requested.
    ///   - capabilities: Use the capability to only list providers with a specific capability. If no capability the provider response will not be filtered on capability.
    ///   - includeTestProviders: If set to true, Providers of TEST financial financial institution kind will be added in the response list. Defaults to false.
    ///   - completion: The completion handler to call when the load request is complete.
    /// - Returns: A Cancellable instance. Call cancel() on this instance if you no longer need the result of the request. Deinitializing this instance will also cancel the request.
    func providers(market: Market? = nil, capabilities: Provider.Capabilities = .all, includeTestProviders: Bool = false, completion: @escaping (Result<[Provider], Error>) -> Void) -> RetryCancellable? {
        var request = GRPCProviderListRequest()
        request.marketCode = market?.code ?? ""
        request.capability = .unknown
        request.includeTestType = includeTestProviders

        return CallHandler(for: request, method: service.listProviders, queue: queue, responseMap: { $0.providers.map { Provider(grpcProvider: $0) }.filter { !$0.capabilities.isDisjoint(with: capabilities) } }, completion: completion)
    }

    /// Lists all markets where there are providers available.
    ///
    /// - Parameter completion: The completion handler to call when the load request is complete.
    /// - Returns: A Cancellable instance. Call cancel() on this instance if you no longer need the result of the request. Deinitializing this instance will also cancel the request.
    func providerMarkets(completion: @escaping (Result<[Market], Error>) -> Void) -> RetryCancellable {
        let request = GRPCProviderMarketListRequest()

        return CallHandler(for: request, method: service.listProviderMarkets, queue: queue, responseMap: { $0.providerMarkets.map { Market(code: $0.code) } }, completion: completion)
    }
}
