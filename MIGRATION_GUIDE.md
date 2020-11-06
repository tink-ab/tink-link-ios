# Migration Guide

## Tink Link 1.0 
- The `redirectURI` property on `Tink.Configuration` has been renamed to `appURI`.
- `TinkLinkViewController` has new initializers.
    - If aggregating with a temporary user, pass a `Tink.Configuration` instead of a configured `Tink` instance:
        ```swift
        let configuration = Tink.Configuration(
            clientID: "YOUR_CLIENT_ID",
            appURI: URL(string: "myapp://callback")!
        )
        let scopes: [Scope] = [.transactions(.read), .accounts(.read)]
        TinkLinkViewController(configuration: configuration, market: "SE", scopes: scopes) { result in
            // Handle result
        }
        ```
    - If aggregating with an access token for an existing user, configure the `userSession` on the `Tink` instance instead of passing it as a parameter when instantiating the `TinkLinkViewController`:
        ```swift
        Tink.shared.userSession = .accessToken("USER_ACCESS_TOKEN")
        let tinkLinkViewController = TinkLinkViewController { result in
            // Handle result
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
                    // Present view controller
                } catch {
                    // Handle error
                }
            }
        }
        ```
- The method for handling redirects is now a static method. Use `Tink.open(_:completion:)` instead of, for example `Tink.shared.open(_:completion:)`.
- The Provider identifier property has been renamed from `id` to `name` and `providerID` to `providerName` when referenced on other models.   
- Handling authentication callbacks on the different methods in `CredentialsContext` have been moved from the `progressHandler` to the new closure parameter `authenticationHandler`. This works the same as authentication is handled in the `TransferContext` and allows you to use the same authentication handling for all credentials operations. 
    ```swift
    Tink.shared.credentialsContext.refresh(credentials, authenticationHandler: { authenticationTask in
        switch authenticationTask {
        case .awaitingSupplementalInformation(let supplementInformationTask):
            // Present supplemental information form
        case .awaitingThirdPartyAppAuthentication(let thirdPartyAppAuthenticationTask):
            // Open third party app
        }
    }, progressHandler: { status in
        switch status {
        case .authenticating:
            // Show that authentication process has started
        case .updating:
            // Show that credentials are updating
        }
    }, completion: { result in
        // Handle result
    })
    ```
- The associated string value in the `updating` status emitted by the different `progressHandlers` have been removed.  
- Renamed errors related to deleted credentials:
    - The `RefreshCredentialsTask.Error.disabled` has been renamed to `RefreshCredentialsTask.Error.deleted`.
    - The `InitiateTransferTask.Error.disabledCredentials` has been renamed to `InitiateTransferTask.Error.credentialsDeleted`.
    - The `AddBeneficiaryTask.Error.disabledCredentials` has been renamed to `AddBeneficiaryTask.Error.credentialsDeleted`.
