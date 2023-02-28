![Platforms](https://img.shields.io/badge/Platforms-iOS_13_14_15_16-brightgreen)
![Swift](https://img.shields.io/badge/Swift-5.7-blue)
![Xcode](https://img.shields.io/badge/Xcode-13_14-yellowgreen)
![SPM](https://img.shields.io/badge/SPM-compatible-orange)

# Tink Link iOS

![Tink Link iOS](https://user-images.githubusercontent.com/3734694/208090845-ee370e16-9a4c-4c4a-bf0a-eea6c7742e74.png)

## Prerequisites

1. iOS >=13.0
2. Xcode >=13.0
3. Go to [Set up your Tink Console account](https://docs.tink.com/resources/getting-started/set-up-your-account) and follow the steps to create a Console account and an app. Make a note of your `client_id`.
4. In Console, go to **App settings** > API client. In the Redirect URIs section, select **Add new redirect URI**. Add a redirect URI to your app. Your redirect URI needs a scheme and host, for example: `awesomeApp://callback`.

## Installation

### Via Swift Package Manager
1. Add `https://github.com/tink-ab/tink-link-ios` in you project dependencies.
2. Set `Dependency Rule` into `Branch` option and set `release/2.0.0` as a value.
3. Make sure your target now has `TinkLink` linked as a dependency.

### Via manual installation

1. Download and unzip the repository.
2. Drag and drop `TinkLink.xcframework` into yout projects `Frameworks` section.
3. Make sure your target now has `TinkLink.xcframework` linked as a dependency with `Embed & Sign` enabled.
4. When finished, import `TinkLink` in your project.

## How to display Tink Link

1. `import TinkLink` inside your ViewContoller and set up a configuration with your client ID and redirect URI:

```swift
import TinkLink

let configuration = Configuration(clientID: <#String#>, redirectURI: <#String#>)
```

2. Set up a market:

```swift
let market = Market(<#String#>)
```

3. Initiate an instance of `UINavigationController` by calling TinkLink API with your configuration and market to use:

```swift
let tinkViewController = Tink.Transactions.connectAccountsForOneTimeAccess(configuration: configuration, market: market) { result in
    // Handle result
}
```

4. Tink Link is designed to be presented either modally or within the navigation stack. Present the view controller by calling `present(_:animated:)` on the presenting view controller:

```swift
present(tinkViewController, animated: true)
```

5. After the user has completed or canceled the flow, the completion handler will be called with a result. A successful authentication will return a result that's dependent on the flow. If something went wrong, the result will contain an error:

```swift
switch result {
    case .success(let connection):
        // Handle successful connection
    case .failure(let error):
        // Handle any errors
}
```

Remember that you are responsible for dismissing the `tinkViewController` by either calling `dismiss(_:animated)` or pop to the desired view controller inside the completion handler:

```swift
let tinkViewController = Tink.Transactions.connectAccountsForOneTimeAccess(configuration: configuration, market: market) { result in
    navigationController.popViewController(animated: true)
    // Handle result
}
navigationController.pushViewController(tinkViewController, animated: true)
```

## Redirect handling

Add a custom URL scheme to handle redirects from a third party authentication flow back to your app:

1. In the Project navigator of your Xcode-project, select the project.
2. In the project editor, select the target.
3. Select Info, then expand URL Types.
4. Select the Add button (+) below the table.
5. In the sheet that appears, enter the same URL scheme as you used for redirect URI inside the URL Schemes field.

For example, if your redirect URI is `awesomeApp://callback`, this section should look like this:
<img width="642" alt="awesomeApp-url-scheme" src="https://user-images.githubusercontent.com/3734694/208428783-b1c5bf61-80c4-4c68-ac03-14544fb20865.png">

For more detailed information about custom URL schemes, go to Apple's developer article [Defining a custom URL scheme for your app](https://developer.apple.com/documentation/xcode/defining-a-custom-url-scheme-for-your-app).

## Samples

`TinkLinkSimpleSample` shows how to build a complete flow for the Transaction product by using Tink Link in the easiest and fastest manner:
- [TinkLinkSimpleSample](Samples/TinkLinkSimpleSample)
