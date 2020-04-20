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

Swift Package Manager is used to integrate Tink Link into your project.

Follow these instructions to [link a target to a package product](https://help.apple.com/xcode/mac/current/#/devb83d64851) and enter this URL `https://github.com/tink-ab/tink-link-ios` when asked for a package repository.

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
| `TINK_CUSTOM_REST_ENDPOINT` | _Optional_ |
| `TINK_REST_CERTIFICATE_URL` | _Optional_ |

## Redirect Handling

You will need to add a custom URL scheme or support universal links to handle redirects from a third party authentication flow back into your app.

Follow the instructions in one of these links to learn how to set this up:

- [Defining a Custom URL Scheme for Your App](https://developer.apple.com/documentation/uikit/inter-process_communication/allowing_apps_and_websites_to_link_to_your_content/defining_a_custom_url_scheme_for_your_app)
- [Allowing Apps and Websites to Link to Your Content](https://developer.apple.com/documentation/uikit/inter-process_communication/allowing_apps_and_websites_to_link_to_your_content)

## Tink Link UI

### Customization 

You can only customize the appearance of Tink Link UI. 
To configure colors or fonts, you can update `Appearance.provider`. This needs to be done before initializing the `TinkLinkViewController`.

#### Colors

|`Color`|Description|
|--------|-------------|
|`background`|Color for the main background of the interface.|
|`secondaryBackground`|Color for content layered on top of the main background.|
|`groupedBackground`|Color for the main background of grouped interface components.|
|`secondaryGroupedBackground`|Color for content layered on top of the main background of grouped interface components.|
|`label`|Primary text color.|
|`secondaryLabel`|Secondary text color.|
|`separator`|Color for separators.|
|`accent`|Colors for buttons, indicators and other similar elements.|
|`expenses`|Color to represent expenses.|
|`income`|Color to represent income.|
|`transfers`|Color to represent transfers.|
|`uncategorized`|Color representing uncategorized transactions.|
|`warning`|Color representing a warning.|
|`critical`|Color representing a critical warning or error.|

```swift
let colorProvider = ColorProvider()
colorProvider.accent = <#UIColor#>
colorProvider.expenses = <#UIColor#>
colorProvider.income = <#UIColor#>
colorProvider.transfers = <#UIColor#>
colorProvider.uncategorized = <#UIColor#>
Appearance.provider.colors = colorProvider
```

#### Themes
You can configure colors and font by providing Tink Link SDK with a `ColorProviding` and `FontProviding` type respectively. Tink Link SDK also provides a `AppearanceProvider` type that can be used to easily customize the Tink Link SDK views. 

```swift
let colorProvider = ColorProvider()
let fontProvider = FontProvider()
colorProvider.accent = <#UIColor#>
colorProvider.expenses = <#UIColor#>
colorProvider.income = <#UIColor#>
colorProvider.transfers = <#UIColor#>
colorProvider.uncategorized = <#UIColor#>
fontProvider.lightFont = <#UIFont#>
fontProvider.regularFont = <#UIFont#>
fontProvider.semiBoldFont = <#UIFont#>
fontProvider.boldFont = <#UIFont#>

Appearance.provider = AppearenceProvider(colors: colorProvider, fonts: fontProvider)
```

## Examples

- [Usage examples](USAGE.md) This document outlines how to use the different classes and types provided by Tink Link.
- [Example apps](Examples) These examples shows how to build a complete aggregation flow using Tink Link.

## Developer Documentation
- [Tink Link iOS Reference](https://tink-ab.github.io/tink-link-ios/tinklink)
- [Tink Link UI iOS Reference](https://tink-ab.github.io/tink-link-ios/tinklinkui)
