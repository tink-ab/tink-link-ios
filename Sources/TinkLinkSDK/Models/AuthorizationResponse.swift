/// The response received when trying to authorize with the `AuthenticationService`.
struct AuthorizationResponse: Decodable {
    let code: AuthorizationCode
}
