# Migration Guide

## Tink Link 1.0 
1.0 is the first stable release of Tink Link. This comes with a few changes to make sure it will work great with the [PFM SDK](https://docs.tink.com/resources/pfm-sdk-ios/overview) and support new features in the future. 

- The `redirectURI` property on `Tink.Configuration` has been renamed to `appURI`.
    ```swift
    let configuration = Tink.Configuration(clientID: "YOUR_CLIENT_ID", appURI: URL(string: "myapp://callback")!)
    Tink.configure(with: configuration)
    ```
- `TinkLinkViewController` has new initializers.
    - If aggregating with a temporary user, pass a `Tink.Configuration` instead of a configured `Tink` instance:
        ```swift
        let scopes: [Scope] = [.transactions(.read), .accounts(.read)]
        let tinkLinkViewController = TinkLinkViewController(configuration: configuration, market: "SE", scopes: scopes) { result in
            // Handle result
        }
        // Present view controller
        ```
    - If aggregating with an existing user, configure the `userSession` on the `Tink` instance instead of instantiating the `TinkLinkViewController` with a `UserSession`:
        ```swift
        Tink.shared.userSession = .accessToken("USER_ACCESS_TOKEN")
        let tinkLinkViewController = TinkLinkViewController { result in
            // Handle result
        }
        // Present view controller
        ```
    - If aggregating using an `AuthorizationCode`, authenticate the user before instantiating the `TinkLinkViewController` using the same initializer as above.
        ```swift
        Tink.shared.authenticateUser(authorizationCode: "AUTHORIZATION_CODE") { result in
            do {
                let accessToken = try result.get()
                DispatchQueue.main.async {
                    Tink.shared.userSession = .accessToken(accessToken.rawValue)
                    let tinkLinkViewController = TinkLinkViewController { result in
                        // Handle result
                    }
                    // Present view controller
                }
            } catch {
                // Handle error
            }
        }
        ```
- The method for handling redirects is now a static method. Use `Tink.open(_:completion:)` instead of, for example `Tink.shared.open(_:completion:)`.
- The Provider model's identifier property has been renamed from `id` to `name`. Other APIs referring to a provider has also been renamed, for example `providerID` on the Credentials model has been renamed to `providerName`.
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
- The associated string in the `updating` status emitted by the different `progressHandlers` have been removed.  
- Errors related to deleted credentials have been renamed:
    - The `RefreshCredentialsTask.Error.disabled` has been renamed to `RefreshCredentialsTask.Error.deleted`.
    - The `InitiateTransferTask.Error.disabledCredentials` has been renamed to `InitiateTransferTask.Error.credentialsDeleted`.
    - The `AddBeneficiaryTask.Error.disabledCredentials` has been renamed to `AddBeneficiaryTask.Error.credentialsDeleted`.

For more details on what changed in 1.0, read the [changelog](https://github.com/tink-ab/tink-link-ios/releases/tag/1.0.0).
