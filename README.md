![Platform](https://img.shields.io/badge/platform-iOS-orange.svg)
![Languages](https://img.shields.io/badge/languages-swift-orange.svg)

# Tink Link iOS

## Prerequisites

1. Create your developer account at [Tink Console](https://console.tink.com)
2. Follow the [getting started guide](https://docs.tink.com/resources/getting-started/set-up-your-account) to retrieve your `client_id` and `client_secret`
3. Add a deep link with scheme and host to your app (`yourapp://host`) to the [list of redirect URIs under your app's settings](https://console.tink.com/overview)

## Requirements

- iOS 10.0
- Xcode 11.3

## Installation

Swift Package Manager is used to integrate Tink Link into your project.

Follow these instructions to [link a target to a package product](https://help.apple.com/xcode/mac/current/#/devb83d64851) and enter this URL `https://github.com/tink-ab/tink-link-sdk-ios` when asked for a package repository.

When finished, you should be able to `import TinkLink` within your project.

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
| `TINK_CUSTOM_GRPC_ENDPOINT` | _Optional_ |
| `TINK_CUSTOM_REST_ENDPOINT` | _Optional_ |
| `TINK_GRPC_CERTIFICATE_URL` | _Optional_ |
| `TINK_REST_CERTIFICATE_URL` | _Optional_ |

## Redirect Handling

You will need to add a custom URL scheme or support universal links to handle redirects from a third party authentication flow back into your app.

Follow the instructions at one of these links for how to set this up:

- [Defining a Custom URL Scheme for Your App](https://developer.apple.com/documentation/uikit/inter-process_communication/allowing_apps_and_websites_to_link_to_your_content/defining_a_custom_url_scheme_for_your_app)
- [Allowing Apps and Websites to Link to Your Content](https://developer.apple.com/documentation/uikit/inter-process_communication/allowing_apps_and_websites_to_link_to_your_content)

## Examples

- [Usage Examples](USAGE.md) This document outlines how to use the different classes and types provided by Tink Link.
- [Provider Selection](Examples/PermanentUserProviderSelection) This example shows how to build a complete aggregation flow using Tink Link.

## Developer Documentation
- [Tink Link iOS Reference](https://tink-ab.github.io/tink-link-ios) 
