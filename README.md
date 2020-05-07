![Platform](https://img.shields.io/badge/platform-iOS-orange.svg)
![Languages](https://img.shields.io/badge/languages-swift-orange.svg)

# Tink Link iOS

## Prerequisites

1. Follow the [getting started guide](https://docs.tink.com/resources/getting-started/set-up-your-account) to retrieve your `client_id`.
2. Add a deep link to your app with scheme and host (`yourapp://host`) to the [list of redirect URIs under your app's settings](https://console.tink.com/overview).

## Requirements

- iOS 11.0
- Xcode 11.4

## Installation
There are two targets TinkLink and TinkLinkUI in the package Tink Link.
- TinkLink is a framework for aggregating bank credentials, you can build your own UI, suitable for enterprise plan customers that are aggregating with permanent users.

- TinkLinkUI is a framework with a predefined flow, a single entrypoint and configurable UI style, you can use this framework to bootstrap your application fast, suitable for customer aggregating with temporary users.

See the difference about the [permanent user and temporary user](https://docs.tink.com/resources/tutorials/permanent-users)

### Integrate TinkLink into your project using Swift Package Manager or CocoaPods

#### Swift Package Manager

Follow these instructions to [link a target to a package product](https://help.apple.com/xcode/mac/current/#/devb83d64851) and enter this URL `https://github.com/tink-ab/tink-link-ios` when asked for a package repository.

When finished, you should be able to `import TinkLink` within your project.

#### Using CocoaPods

Add `pod 'TinkLink'` to your project's Podfile. Run `pod install` to install the TinkLink framework.

When finished, you should be able to `import TinkLink` within your project.

Use `pod update TinkLink` to update to the newer version.

### Integrate TinkLinkUI into your project using CocoaPods.
#### Using CocoaPods

Add `pod 'TinkLinkUI'` to your project's Podfile. Run `pod install` to install the TinkLinkUI framework.

When finished, you should be able to `import TinkLink` and `import TinkLinkUI` within your project.

Use `pod update TinkLinkUI` to update to the newer version.

## Configuration

To start using Tink Link, you will need to configure a `Tink` instance with your client ID and redirect URI.

```swift
let configuration = try! Tink.Configuration(clientID: <#String#>, redirectURI: <#URL#>)
Tink.configure(with: configuration)
```

## Redirect handling

You will need to add a custom URL scheme or support universal links to handle redirects from a third party authentication flow back into your app.

Follow the instructions in one of these links to learn how to set this up:

- [Defining a Custom URL Scheme for Your App](https://developer.apple.com/documentation/uikit/inter-process_communication/allowing_apps_and_websites_to_link_to_your_content/defining_a_custom_url_scheme_for_your_app)
- [Allowing Apps and Websites to Link to Your Content](https://developer.apple.com/documentation/uikit/inter-process_communication/allowing_apps_and_websites_to_link_to_your_content)

## Tutorials
- [Tink Link Tutorial](https://docs.tink.com/resources/tutorials/tink-link-sdk-ios-tutorial) This tutorial outlines how to use the different classes and types provided by TinkLink.
- [Tink Link UI Tutorial](https://docs.tink.com/resources/tutorials/tink-link-ui-sdk-ios-tutorial) This tutorial outlines how integrate Tink Link UI in your app.

## Examples
These examples shows how to build a complete aggregation flow using TinkLink or TinkLinkUI.
- [Permanent User](Examples/PermanentUserExample) 
- [Permanent User (SwiftUI)](Examples/PermanentUserExample)
- [Tink Link UI](Examples/TinkLinkUIExample)

## Developer Documentation
- [Tink Link iOS Reference](https://tink-ab.github.io/tink-link-ios)
- [Tink Link UI iOS Reference](https://tink-ab.github.io/tink-link-ios/tinklinkui)
