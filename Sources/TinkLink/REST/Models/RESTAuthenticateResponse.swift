/// The response received when trying to authenticate with the `UserService`.
struct RESTAuthenticateResponse: Decodable {
    let accessToken: String
}
