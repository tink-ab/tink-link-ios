# Requirements
* iOS 13.
* Xcode 14.1.
* Swift 5.7.

# Dependencies update
* ## Swift Package Manager
In case you use SPM for dependency management you can update Tink Link up to the next major version by following these steps:
1. Go to project settings and select `Package Dependencies` tab.
2. Double click on `tink-link-ios`.
3. Set `Rules` version to `Up to Next Major` equals `2.0.0`.

* ## Cocoapods
In case you use Cocoapods as a dependency manager you can update Tink Link up to the next major version by following these steps:
1. In your `Podfile` make sure that iOS platform requirement is set to `13` or higher, like:
```
platform :ios, '13.0'
```
2. Now in your `Podfile` you can update TinkLink version up to the next major, such as:
```
pod 'TinkLink', '~> 2'
```
3. In case if you are using `TinkLinkUI` you need to remove this pod from your Podfile. This pod is deprecated.
```
p̶o̶d̶-'T̶i̶n̶k̶L̶i̶n̶k̶U̶I̶'
```

4. Finally make Cocoapods update dependencies:
```
pod install
```

# Declaration changes
1. Make sure that `Minimum Deployments` iOS version for your target is `>= 13.0`.

2. Check that `TinkLinkUI` is removed from the `Frameworks, Libraries, and Embedded Content` configuration section of your target. This framework is deprecated.

3. `TinkLinkUI` import statement needs to be removed from your source code.

4. `Tink` general type has been transformed from `class` into `enum` and is not intended to be initialized. Use it to access product subtypes.

5. `TinkLinkConfiguration` type is unavailable now. Use `Configuration` type instead.

6. `Appearance` type is unavailable now. TinkLink's appearance can now be customized via [Tink Console](https://console.tink.com).

7. `TinkLinkUIError` type is unavailable now. Rely on new `TinkError` type.

8. `TinkLinkViewController` and its related `Operation`, `ProviderPredicate`, `PrefillStrategy` and `AuthenticationStrategy` types are unavailable now. Use `Tink` and its nested types to create the view controller for each product.

# Account Aggregation product migration guide
## 1. [Snapshot aggregation: Authorize](https://docs.tink.com/resources/tink-link-web/tink-link-web-api-reference-account-aggregation#snapshot-aggregation)

* Implementation with Tink Link iOS version prior 2.0:
```
let market = Market(code: "SE")

let providerPredicate = TinkLinkViewController.ProviderPredicate.kinds(.all)

let configuration = TinkLinkConfiguration(
        clientID: "YOUR_CLIENT_ID",
        appURI: URL(string: "YOUR_APP_URI")!,
        callbackURI: URL(string: "YOUR_CALLBACK_URI")!,
        environment: .production)

let scopes = [
    Scope.statistics(.read),
    Scope.transactions(.read), .categories(.read),
    Scope.accounts(.read)
]

let viewController = TinkLinkViewController(configuration: configuration, 
                                            market: market, 
                                            scopes: scopes, 
                                            providerPredicate: providerPredicate) { result in
    print(result)
}

present(viewController, animated: true)
```

* Implementation with Tink Link 2.0:
```
let configuration = Configuration(clientID: "YOUR_CLIENT_ID", redirectURI: "YOUR_REDIRECT_URI")

let market = Market("SE")

let scopes = [
    Scope.statistics(.read),
    Scope.transactions(.read), .categories(.read),
    Scope.accounts(.read)
]

let viewController = Tink.AccountAggregation.authorizeForOneTimeAccess(configuration: configuration, 
                                                                       market: market, 
                                                                       scope: scopes) { (result: Result<OneTimeConnection, TinkError>) in
    print(result)
}

present(viewController, animated: true)
```

## 2. [Permanent user aggregation: Add credentials](https://docs.tink.com/resources/tink-link-web/tink-link-web-api-reference-account-aggregation#add-credentials)

* Implementation with Tink Link iOS version prior 2.0:
```
let market = Market(code: "SE")

let configuration = TinkLinkConfiguration(
        clientID: "YOUR_CLIENT_ID",
        appURI: URL(string: "tinklink://example")!,
        callbackURI: URL(string: "tinklink://example")!,
        environment: Tink.Environment.production)

let authenticationStrategy = AuthenticationStrategy.authorizationCode("YOUR_AUTHORIZATION_CODE")

let providerPredicate = TinkLinkViewController.ProviderPredicate.kinds(.all)

let operation = TinkLinkViewController.Operation.create(providerPredicate: providerPredicate)

let tinkLinkViewController = TinkLinkViewController(configuration: configuration,
                                                    market: market,
                                                    authenticationStrategy: authenticationStrategy,
                                                    operation: operation) { result in
    print(result)
}

present(tinkLinkViewController, animated: true)
```

* Implementation with Tink Link 2.0:
```
let configuration = Configuration(clientID: "YOUR_CLIENT_ID", redirectURI: "YOUR_REDIRECT_URI")

let authorizationCode = AuthorizationCode("YOUR_AUTHORIZATION_CODE")

let market = Market("SE")

let viewController = Tink.AccountAggregation.addCredentials(configuration: configuration, 
                                                            market: market, 
                                                            authorizationCode: authorizationCode) { (result: Result<Credentials.ID, TinkError>) in
    print(result)
}

present(viewController, animated: true)
```

## 3. [Permanent user aggregation: Authenticate credentials](https://docs.tink.com/resources/tink-link-web/tink-link-web-api-reference-account-aggregation#authenticate-credentials)

* Implementation with Tink Link iOS version prior 2.0:
```
let market = Market(code: "SE")
        
let configuration = TinkLinkConfiguration(
        clientID: "YOUR_CLIENT_ID",
        appURI: URL(string: "tinklink://example")!,
        callbackURI: URL(string: "tinklink://example")!,
        environment: Tink.Environment.production)

let authenticationStrategy = AuthenticationStrategy.authorizationCode("YOUR_AUTHORIZATION_CODE")

let credentialsID = Credentials.ID("YOUR_CREDENTIALS_ID")

let operation = TinkLinkViewController.Operation.authenticate(credentialsID: credentialsID)

let tinkLinkViewController = TinkLinkViewController(configuration: configuration,
                                                    market: market,
                                                    authenticationStrategy: authenticationStrategy,
                                                    operation: operation) { result in
    print(result)
}

present(tinkLinkViewController, animated: true)
```

* Implementation with Tink Link 2.0:
```
let configuration = Configuration(clientID: "YOUR_CLIENT_ID", redirectURI: "YOUR_REDIRECT_URI")
        
let authorizationCode = AuthorizationCode("YOUR_AUTHORIZATION_CODE")

let credentialsID = Credentials.ID("YOUR_CREDENTIALS_ID")

let viewController = Tink.AccountAggregation.authenticateCredentials(configuration: configuration, 
                                                                     authorizationCode: authorizationCode, 
                                                                     credentialsID: credentialsID) { (result: Result<Credentials.ID, TinkError>) in
    print(result)
}

present(viewController, animated: true)

```

## 4. [Permanent user aggregation: Refresh credentials](https://docs.tink.com/resources/tink-link-web/tink-link-web-api-reference-account-aggregation#refresh-credentials)

* Implementation with Tink Link iOS version prior 2.0:
```
let market = Market(code: "SE")
        
let configuration = TinkLinkConfiguration(
        clientID: "YOUR_CLIENT_ID",
        appURI: URL(string: "tinklink://example")!,
        callbackURI: URL(string: "tinklink://example")!,
        environment: Tink.Environment.production)

let authenticationStrategy = AuthenticationStrategy.authorizationCode("YOUR_AUTHORIZATION_CODE")

let credentialsID = Credentials.ID("YOUR_CREDENTIALS_ID")

let operation = TinkLinkViewController.Operation.refresh(credentialsID: credentialsID)

let tinkLinkViewController = TinkLinkViewController(configuration: configuration,
                                                    market: market,
                                                    authenticationStrategy: authenticationStrategy,
                                                    operation: operation) { result in
    print(result)
}

present(tinkLinkViewController, animated: true)
```

* Implementation with Tink Link 2.0:

```
let configuration = Configuration(clientID: "YOUR_CLIENT_ID", redirectURI: "YOUR_REDIRECT_URI")

let authorizationCode = AuthorizationCode("YOUR_AUTHORIZATION_CODE")

let credentialsID = Credentials.ID("YOUR_CREDENTIALS_ID")

let viewController = Tink.AccountAggregation.refreshCredentials(configuration: configuration,
                                                                authorizationCode: authorizationCode,
                                                                credentialsID: credentialsID,
                                                                completion: { (result: Result<Credentials.ID, TinkError>) in
    print(result)
})

present(viewController, animated: true)
```

## 5. Permanent user aggregation: Update
Call is not available in Tink Link 2.0. Use [Extend consent](https://docs.tink.com/resources/tink-link-web/tink-link-web-api-reference-account-aggregation#extend-consent) instead.

* Implementation with Tink Link 2.0:
```
let configuration = Configuration(clientID: "YOUR_CLIENT_ID", redirectURI: "YOUR_REDIRECT_URI")

let authorizationCode = AuthorizationCode("YOUR_AUTHORIZATION_CODE")

let credentialsID = Credentials.ID("YOUR_CREDENTIALS_ID")

let viewController = Tink.AccountAggregation.extendConsent(configuration: configuration,
                                                           authorizationCode: authorizationCode,
                                                           credentialsID: credentialsID,
                                                           completion: { (result: Result<Credentials.ID, TinkError>) in
    print(result)
})

present(viewController, animated: true)
```
