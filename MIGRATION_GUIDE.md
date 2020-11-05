# Migration Guide

## Tink Link 1.0 
- The `redirectURI` property on `Tink.Configuration` has been renamed to `appURI`.
- `TinkLinkViewController` has new initializers.
    - If aggregating with a temporary user, pass a `Tink.Configuration` instead of a configured `Tink` instance:
        ```swift
        let configuration = Tink.Configuration(
            clientID: "YOUR_CLIENT_ID",
            appURI: URL(string: "myapp://callback")!,
            environment: .production
        )
        TinkLinkViewController(configuration: configuration, market: "SE", scopes: scopes) { result in
            print(result)
        }
        ```
    - If aggregating with an access token for an existing user, configure the `userSession` on the `Tink` instance instead of passing it as a parameter when instantiating the `TinkLinkViewController`:
        ```swift
        Tink.shared.userSession = .accessToken("USER_ACCESS_TOKEN")
        let tinkLinkViewController = TinkLinkViewController(operation: .create(providerPredicate: .kinds(.all))) { result in
            print(result)
        }
        ```
    - If aggregating using an `AuthorizationCode`, authenticate the user before instantiating the `TinkLinkViewController` using the same initializer as above.
        ```swift
        Tink.shared.authenticateUser(authorizationCode: AuthorizationCode(authorizationCode)) { (result) in
            DispatchQueue.main.async {
                do {
                    let accessToken = try result.get()
                    Tink.shared.userSession = .accessToken(accessToken.rawValue)
                    let tinkLinkViewController = TinkLinkViewController { result in
                        print(result)
                    }
                    self.present(tinkLinkViewController, animated: true)
                } catch {
                    // Handle error
                }
            }
        }
        ```
- The method for handling redirects is now a static method. Use `Tink.open(_:completion:)` instead of, for example `Tink.shared.open(_:completion:)`.
