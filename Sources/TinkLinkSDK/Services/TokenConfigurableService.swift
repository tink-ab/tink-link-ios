import GRPC

protocol TokenConfigurableService: AnyObject {
    var defaultCallOptions: CallOptions { get set }

    func configure(_ accessToken: AccessToken)
}

extension TokenConfigurableService {
    func configure(_ accessToken: AccessToken) {
        defaultCallOptions.addAccessToken(accessToken.rawValue)
    }
}
