# Headless Example

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
    
2. Set a valid user access token. If you don't have one already, please follow our [guide](https://docs.tink.com/resources/getting-started/get-access-token) on how to generate a new API token. Note that these can expire, so make sure that you're using one that's currently active.
    ```swift
    Tink.shared.userSession = .accessToken(<#String#>)
    ```

## Running the example app
1. Open `HeadlessExample.xcodeproj` in Xcode.
2. Press the run button. If all went well, this should launch a simulator with the sample app running.
