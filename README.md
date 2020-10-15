![Platform](https://img.shields.io/badge/platform-iOS-orange.svg)
![Languages](https://img.shields.io/badge/languages-swift-orange.svg)

# Tink Link iOS

![Tink Link](https://images.ctfassets.net/tmqu5vj33f7w/4YdZUwzfmUjvNKO0tHvKVj/ec14ed052771e3ef10156c29ccf004f0/overview.png)

## Prerequisites

1. Follow the [getting started guide](https://docs.tink.com/resources/getting-started/set-up-your-account) to retrieve your `client_id`.
2. Add a deep link to your app with scheme and host (`yourapp://host`) to the [list of redirect URIs under your app's settings](https://console.tink.com/overview).

## Requirements

- iOS 11.0
- Xcode 11.4

## Installation

See the difference about the [permanent user and temporary user](https://docs.tink.com/resources/tutorials/permanent-users)
There are two targets in the package Tink Link.
- `TinkLink` is a framework for aggregating bank credentials, you can build your own UI, suitable for enterprise plan customers that are aggregating with permanent users.
- `TinkLinkUI` is a framework with a predefined flow, a single entrypoint and configurable UI style, you can use this framework to bootstrap your application fast.

#### Using Swift Package Manager

Follow these instructions to [link a target to a package product](https://help.apple.com/xcode/mac/current/#/devb83d64851) and enter this URL `https://github.com/tink-ab/tink-link-ios` when asked for a package repository.

When finished, you should be able to `import TinkLink` and  `import TinkLinkUI` within your project.

> If you only need the headless SDK you don't need to import `TinkLinkUI` within your project.

#### Using CocoaPods
Refer to their [guide](https://guides.cocoapods.org/using/using-cocoapods.html) for usage and installation instructions.

1. Add TinkLink and TinkLinkUI to your Podfile.
    ```
    pod "TinkLink"
    pod "TinkLinkUI"
    ```

2. Run `pod install` in your project directory.

3. Open your `.xcworkspace` file to see the project in Xcode.

> If you only need the headless SDK you don't need to include `pod "TinkLinkUI"` in your Podfile. 

#### Using Carthage
Refer to these [instructions](https://github.com/Carthage/Carthage#installing-carthage) for usage and installation details.

1. Add `github "tink-ab/tink-link-ios"` to your project's Cartfile. 
2. Run `carthage update` in your project directory.
3. In your copy frameworks run script, add these paths to your input and output file lists respectivly.
```
$(SRCROOT)/Carthage/Build/iOS/TinkCore.framework
$(SRCROOT)/Carthage/Build/iOS/TinkLink.framework
$(SRCROOT)/Carthage/Build/iOS/TinkLinkUI.framework
$(SRCROOT)/Carthage/Build/iOS/Down.framework
$(SRCROOT)/Carthage/Build/iOS/Kingfisher.framework
```
```
$(BUILT_PRODUCTS_DIR)/$(FRAMEWORKS_FOLDER_PATH)/TinkCore.framework
$(BUILT_PRODUCTS_DIR)/$(FRAMEWORKS_FOLDER_PATH)/TinkLink.framework
$(BUILT_PRODUCTS_DIR)/$(FRAMEWORKS_FOLDER_PATH)/TinkLinkUI.framework
$(BUILT_PRODUCTS_DIR)/$(FRAMEWORKS_FOLDER_PATH)/Down.framework
$(BUILT_PRODUCTS_DIR)/$(FRAMEWORKS_FOLDER_PATH)/Kingfisher.framework
```

When finished, you should be able to `import TinkLink`  and `import TinkLinkUI` within your project.

> If you only need the headless SDK you don't need to include `TinkLinkUI.framework`, `Down.framework` and `Kingfisher.framework`.

## How to display Tink Link

1. Import the SDK and configure Tink with your client ID and redirect URI.
    ```swift
    import TinkLink
    import TinkLinkUI
    
    let configuration = try! Tink.Configuration(clientID: <#String#>, redirectURI: <#URL#>)
    Tink.configure(with: configuration)
    ```

2. Define the list of [scopes](https://docs.tink.com/api/#introduction-authentication-authorization-scopes) based on the type of data you want to fetch. For example, to retrieve accounts and transactions, define these scopes:
    ```swift
    let scopes: [Scope] = [
        .accounts(.read), 
        .transactions(.read)
    ]
    ```

3. Create a `TinkLinkViewController` with the market and list of scopes to use.
    ```swift
    let tinkLinkViewController = TinkLinkViewController(market: "SE", scopes: scopes) { result in 
        // Handle result
    }
    ```
    
4. Tink Link is designed to be presented modally. Present the view controller by calling `present(_:animated:)` on the presenting view controller. 
    ```swift
    present(tinkLinkViewController, animated: true)
    ```

5. After the user has completed or cancelled the aggregation flow, the completion handler will be called with a result. A successful authentication will return a result that contains an authorization code that you can [exchange for an access token](https://docs.tink.com/resources/getting-started/retrieve-access-token). If something went wrong the result will contain an error.
    ```swift
    do {
        let authorizationCode = try result.get()
        // Exchange the authorization code for a access token.
    } catch {
        // Handle any errors
    }
    ```

## Redirect handling

You will need to add a custom URL scheme or support universal links to handle redirects from a third party authentication flow back into your app.

Follow the instructions in one of these links to learn how to set this up:

- [Defining a Custom URL Scheme for Your App](https://developer.apple.com/documentation/uikit/inter-process_communication/allowing_apps_and_websites_to_link_to_your_content/defining_a_custom_url_scheme_for_your_app)
- [Allowing Apps and Websites to Link to Your Content](https://developer.apple.com/documentation/uikit/inter-process_communication/allowing_apps_and_websites_to_link_to_your_content)

## Examples
These examples shows how to build a complete aggregation flow using TinkLink or TinkLinkUI.
- [Tink Link](Examples/TinkLinkExample)
- [Headless](Examples/HeadlessExample) 
- [Headless (SwiftUI)](Examples/HeadlessExample-SwiftUI)

## Documentation
- [Tink Link for iOS](https://docs.tink.com/resources/tink-link-ios/tink-link-ios-overview)
