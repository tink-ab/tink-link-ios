![Platform](https://img.shields.io/badge/platform-iOS-orange.svg)
![Languages](https://img.shields.io/badge/languages-swift-orange.svg)

# Tink Link iOS

## Prerequisites

1. Follow the [getting started guide](https://docs.tink.com/resources/getting-started/set-up-your-account) to retrieve your `client_id`.
2. Make sure you are an Enterprise customer with permanent users enabled.
3. Add a deep link to your app with scheme and host (`yourapp://host`) to the [list of redirect URIs under your app's settings](https://console.tink.com/overview).

## Requirements

- iOS 11.0
- Xcode 11.3

## Installation
There are two targets TinkLink and TinkLinkUI in the package Tink Link.
- TinkLink is a framework for aggregating bank credentials but without any UI, you can build your flow with your UI component, suitable for enterprise plan customer that aggregating using permanent user.

- TinkLinkUI is a framework with a predefined flow, a single entrypoint and configurable UI style, you can use this framework to bootstrap your application fast, suitable for customer aggregating with temporary user.

See the difference about the [permanent user and temporary user](https://docs.tink.com/resources/tutorials/permanent-users)

### Integrate TinkLink into your project using Swift Package Manager or CocoaPods
- Using Swift Package Manager

Follow these instructions to [link a target to a package product](https://help.apple.com/xcode/mac/current/#/devb83d64851) and enter this URL `https://github.com/tink-ab/tink-link-ios` when asked for a package repository.

When finished, you should be able to `import TinkLink` within your project.

- Using CocoaPods

Add `pod 'TinkLink'` to your project's Podfile. Run `pod install` to install the TinkLink framework.

When finished, you should be able to `import TinkLink` within your project.

Use `pod update TinkLink` to update to the newer version.

### Integrate TinkLinkUI into your project using CocoaPods.
- Using CocoaPods

Similar to using TinkLink, Add `pod 'TinkLinkUI'` to your project's Podfile. Run `pod install` to install the TinkLinkUI framework.

When finished, you should be able to `import TinkLink` and `import TinkLinkUI` within your project.

Use `pod update TinkLinkUI` to update to the newer version.

## Configuration

To start using Tink Link, you will need to configure a `Tink` instance with your client ID and redirect URI.

### Swift

```swift
let configuration = try! Tink.Configuration(clientID: <#String#>, redirectURI: <#URL#>)
Tink.configure(with: configuration)
```

### Environment Variables

The shared instance of Tink can also be configured using environment variables defined in your application's target run scheme.

| Key                         | Value      |
| --------------------------- | ---------- |
| `TINK_CLIENT_ID`            | String     |
| `TINK_REDIRECT_URI`         | String     |
| `TINK_CUSTOM_REST_ENDPOINT` | _Optional_ |
| `TINK_REST_CERTIFICATE_URL` | _Optional_ |

## Redirect Handling

You will need to add a custom URL scheme or support universal links to handle redirects from a third party authentication flow back into your app.

Follow the instructions in one of these links to learn how to set this up:

- [Defining a Custom URL Scheme for Your App](https://developer.apple.com/documentation/uikit/inter-process_communication/allowing_apps_and_websites_to_link_to_your_content/defining_a_custom_url_scheme_for_your_app)
- [Allowing Apps and Websites to Link to Your Content](https://developer.apple.com/documentation/uikit/inter-process_communication/allowing_apps_and_websites_to_link_to_your_content)

## Examples

- [Usage examples](USAGE.md) This document outlines how to use the different classes and types provided by TinkLink.
- [Example apps](Examples) These examples shows how to build a complete aggregation flow using TinkLink and TinkLinkUI.

## Developer Documentation
- [Tink Link iOS Reference](https://tink-ab.github.io/tink-link-ios)
