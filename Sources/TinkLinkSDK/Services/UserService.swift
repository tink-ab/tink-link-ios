import Foundation
import GRPC

final class UserService {
    let connection: ClientConnection
    let defaultCallOptions: CallOptions
    let restURL: URL

    private var session: URLSession
    private var sessionDelegate: URLSessionDelegate?

    convenience init(tinkLink: TinkLink = .shared) {
        let client = tinkLink.client
        self.init(
            connection: client.connection,
            defaultCallOptions: client.defaultCallOptions,
            restURL: client.restURL,
            certificates: client.restCertificateURL
                .flatMap { try? Data(contentsOf: $0) }
                .map { [$0] } ?? []
        )
    }

    init(connection: ClientConnection, defaultCallOptions: CallOptions, restURL: URL, certificates: [Data]) {
        self.connection = connection
        self.defaultCallOptions = defaultCallOptions
        self.restURL = restURL
        if certificates.isEmpty {
            self.session = .shared
        } else {
            self.sessionDelegate = CertificatePinningDelegate(certificates: certificates)
            self.session = URLSession(configuration: .ephemeral, delegate: sessionDelegate, delegateQueue: nil)
        }
    }

    private lazy var service = UserServiceServiceClient(connection: connection, defaultCallOptions: defaultCallOptions)

    func createAnonymous(market: Market? = nil, locale: Locale, origin: String? = nil, completion: @escaping (Result<AccessToken, Error>) -> Void) -> RetryCancellable {
        var request = GRPCCreateAnonymousRequest()
        request.market = market?.code ?? ""
        request.locale = locale.identifier
        request.origin = origin ?? ""

        return CallHandler(for: request, method: service.createAnonymous, responseMap: { AccessToken($0.accessToken) }, completion: completion)
    }

    func authenticate(code: AuthorizationCode, completion: @escaping (Result<AuthenticateResponse, Error>) -> Void) -> RetryCancellable? {
        guard var urlComponents = URLComponents(url: restURL, resolvingAgainstBaseURL: false) else {
            preconditionFailure("Invalid restURL")
        }

        urlComponents.path = "/link/v1/authentication/token"
        var urlRequest = URLRequest(url: urlComponents.url!)
        urlRequest.httpMethod = "POST"
        urlRequest.setValue("application/json; charset=utf-8", forHTTPHeaderField: "Content-Type")

        do {
            let body = ["code": code.rawValue]
            urlRequest.httpBody = try JSONEncoder().encode(body)
        } catch {
            completion(.failure(error))
            return nil
        }

        let serviceRetryCanceller = URLSessionRequestRetryCancellable<AuthenticateResponse, AuthorizationError>(session: session, request: urlRequest, completion: completion)
        serviceRetryCanceller.start()

        return serviceRetryCanceller
    }


    func marketAndLocale(completion: @escaping (Result<(Market, Locale), Error>) -> Void) -> RetryCancellable? {
        let request = GRPCGetProfileRequest()
        return CallHandler(for: request, method: service.getProfile, responseMap: { response -> (Market, Locale) in
            let profile = response.userProfile
            return (Market(code: profile.market), Locale(identifier: profile.locale))
        }, completion: completion)
    }
}
