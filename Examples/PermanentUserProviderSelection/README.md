# Permanent User Example

## Prerequisites
1. Follow the [getting started guide](https://docs.tink.com/resources/getting-started/set-up-your-account) to retrieve your `client_id`.
2. Make sure you are an Enterprise customer with permanent users enabled.
3. Add a `link-demo://tink`) to the [list of redirect URIs under your app's settings](https://console.tink.com/overview).

## Configuration
Before running the example project open `AppDelegate.swift` and configure the following:

1. Configure `Tink` with your client ID.
    ```swift
    let configuration = try! Tink.Configuration(clientID: <#String#>, redirectURI: URL(string: "link-demo://tink")!)
    Tink.configure(with: configuration)
    ```
    
2. Set a valid access token.
    ```swift
    Tink.shared.userSession = .accessToken(<#String#>)
    ```
