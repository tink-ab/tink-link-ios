/// The response received when trying to authorize with the `AuthenticationService`.
struct RESTAuthorizationResponse: Decodable {
    let code: String
}
