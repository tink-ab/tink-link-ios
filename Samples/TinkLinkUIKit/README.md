![Xcode](https://img.shields.io/badge/Xcode-15_16-red)
![Swift](https://img.shields.io/badge/Swift-5.10-brightred)
![Platforms](https://img.shields.io/badge/Platforms-iOS_15_16_17_18-blue)

# Tink Link + WKWebView integration example

This example app demonstrates how to integrate Tink Link using a WKWebView on iOS. It follows the steps described in [Integrate One-Time Payments in iOS apps
](https://docs.tink.com/resources/payments/one-time-payments/integrate-one-time-payments-in-ios-apps) guide.

## Steps

### 1. Associate a universal link or custom URL scheme with your app
* Universal link supported app.
  Follow [Supporting associated domains](https://developer.apple.com/documentation/xcode/supporting-associated-domains) guide:
  <img width="1213" alt="image" src="https://github.com/user-attachments/assets/6f92e49f-0bd5-4686-9dcb-b215daa74f13" />
  (Replace `applinks:tink.com` with your domain).

* Custom URL scheme
  Add you app supported URL scheme in `URL Types` list of your project target configuration, using your own URL scheme:
  <img width="1213" alt="image" src="https://github.com/user-attachments/assets/ab351fa5-c560-4eb6-82b5-a650a50471df" />
  (Replace `tink` with your scheme).

We recommend using universal links as they avoid unnecessary redirect dialogs in Safari.

### 2. Configure Tink Link URL parameters
Set up the Tink Link URL with your credentials and required parameters.

[View code ↗](https://github.com/tink-ab/tink-link-ios/blob/81dd134ec98fad9ab7e040f28c8cc15dc625ebdc/Samples/TinkLinkUIKit/TinkLinkUIKit/ViewController.swift#L3-L11)

### 3. Extend `Notification.Name`
Add notification names for handling redirects.

[View code ↗](https://github.com/tink-ab/tink-link-ios/blob/81dd134ec98fad9ab7e040f28c8cc15dc625ebdc/Samples/TinkLinkUIKit/TinkLinkUIKit/AppDelegate.swift#L29-L32)

### 4. Extend `UIApplicationDelegate`
Add universal link and/or custom URL scheme handlers in `UIApplicationDelegate`.

[View code ↗](https://github.com/tink-ab/tink-link-ios/blob/81dd134ec98fad9ab7e040f28c8cc15dc625ebdc/Samples/TinkLinkUIKit/TinkLinkUIKit/AppDelegate.swift#L14-L27)

### 5. Extend `UISceneDelegate`
If needed, add universal link and/or custom URL scheme handlers in `UISceneDelegate` as well.

[View code ↗](https://github.com/tink-ab/tink-link-ios/blob/81dd134ec98fad9ab7e040f28c8cc15dc625ebdc/Samples/TinkLinkUIKit/TinkLinkUIKit/SceneDelegate.swift#L14-L20)

### 6. Create a `LinkViewController`
Implement a `LinkViewController` by subclassing `UIViewController` and adding `WKWebView` & `SFSafariViewController` workflows.

[View code ↗](https://github.com/tink-ab/tink-link-ios/blob/81dd134ec98fad9ab7e040f28c8cc15dc625ebdc/Samples/TinkLinkUIKit/TinkLinkUIKit/LinkViewController.swift#L5)

### 7. Handle the callback response
Parse the `callback` query response parameters to handle the response.

[View code ↗](https://github.com/tink-ab/tink-link-ios/blob/81dd134ec98fad9ab7e040f28c8cc15dc625ebdc/Samples/TinkLinkUIKit/TinkLinkUIKit/LinkViewController.swift#L32-L34)

## Support
If you have any questions or need assistance, please contact [Tink Support](https://docs.tink.com/resources/support).
