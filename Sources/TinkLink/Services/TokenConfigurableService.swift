import GRPC

protocol TokenConfigurableService: AnyObject {
    func configure(_ accessToken: AccessToken)
}

protocol CallOptionsProviding: AnyObject {
    var defaultCallOptions: CallOptions { get set }
}
extension TokenConfigurableService where Self: CallOptionsProviding {
    func configure(_ accessToken: AccessToken) {
        defaultCallOptions.addAccessToken(accessToken.rawValue)
    }
}
