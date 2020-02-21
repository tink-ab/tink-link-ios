/// The response received when trying to authenticate with the `UserService`.
struct AuthenticateResponse: Decodable {
    let accessToken: AccessToken
}
