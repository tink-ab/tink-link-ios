![Platforms](https://img.shields.io/badge/Platforms-iOS_13_14_15_16-brightgreen)
![Swift](https://img.shields.io/badge/Swift-5.7-blue)
![Xcode](https://img.shields.io/badge/Xcode-13_14-yellowgreen)
![SPM](https://img.shields.io/badge/SPM-compatible-orange)

# Tink Link iOS

![Tink Link iOS](https://user-images.githubusercontent.com/3734694/208090845-ee370e16-9a4c-4c4a-bf0a-eea6c7742e74.png)

## Prerequisites

1. Go to [Set up your Tink Console account](https://docs.tink.com/resources/getting-started/set-up-your-account) and follow the steps to create a Console account and an app. Make a note of your `client_id`.
2. In Console, go to **App settings** > API client. In the Redirect URIs section, select **Add new redirect URI**. Add a redirect URI to your app. Your redirect URI needs a scheme and host, for example: `awesomeApp://callback`.

## Requirements

1. iOS >=13.0
2. Xcode >=13.0

## Installation

### Using Swift Package Manager
1. Add `https://github.com/tink-ab/tink-link-ios` in you project dependencies.
2. Set `Dependency Rule` into `Branch` option and set `release/2.0.0` as a value.
3. Make sure your target now has `TinkLink` linked as a dependency.

### Using CocoaPods
1. Refer to `CocoaPods` [guide](https://guides.cocoapods.org/using/using-cocoapods.html) for usage and installation instructions.
2. Add `TinkLink` to your Podfile.
    ```
    pod 'TinkLink'
    ```
3. Run `pod install` in your project directory.

4. Open your `.xcworkspace` file to see the project in Xcode.

### Using manual installation

1. Download and unzip the repository.
2. Drag and drop `TinkLink.xcframework` into yout projects `Frameworks` section.
3. Make sure your target now has `TinkLink.xcframework` linked as a dependency with `Embed & Sign` enabled.
4. When finished, import `TinkLink` in your project.

## Launching the SDK

To launch the SDK in your iOS app, please see the product specific documentation.

|                       |                                                                                                                    |                                                                                                                                           |                                                                                  |
| --------------------- | ------------------------------------------------------------------------------------------------------------------ | ----------------------------------------------------------------------------------------------------------------------------------------- | -------------------------------------------------------------------------------- |
| **Account Check**     | [Getting started](https://docs.tink.com/resources/account-check/verify-your-first-account)                         | [Setup and integrate](https://docs.tink.com/resources/account-check/setup-and-integrate-account-check#tink-link-for-ios)                  | [SDK reference](https://tink-ab.github.io/tink-link-ios/documentation/tinklink/) |
| **Expense Check**     | [Getting started](https://docs.tink.com/resources/expense-check/fetch-your-first-expense-check-report)             | [Setup and integrate](https://docs.tink.com/resources/expense-check/setup-and-integrate-expense-check#tink-link-for-ios)                  | [SDK reference](https://tink-ab.github.io/tink-link-ios/documentation/tinklink/) |
| **Income Check**      | [Getting started](https://docs.tink.com/resources/income-check/fetch-your-first-income-check-report)               | [Setup and integrate](https://docs.tink.com/resources/income-check/setup-and-integrate-income-check#tink-link-for-ios)                    | [SDK reference](https://tink-ab.github.io/tink-link-ios/documentation/tinklink/) |
| **One-time payments** | [Getting started](https://docs.tink.com/resources/payments/one-time-payments/initiate-your-first-one-time-payment) | [Setup and integrate](https://docs.tink.com/resources/payments/one-time-payments/setup-and-integrate-one-time-payments#tink-link-for-ios) | [SDK reference](https://tink-ab.github.io/tink-link-ios/documentation/tinklink/) |
| **Risk Insights**     | [Getting started](https://docs.tink.com/resources/risk-insights/fetch-your-first-risk-insights-report)             | [Setup and integrate](https://docs.tink.com/resources/risk-insights/setup-and-integrate-risk-insights#tink-link-for-ios)                  | [SDK reference](https://tink-ab.github.io/tink-link-ios/documentation/tinklink/) |
| **Transactions**      | [Getting started](https://docs.tink.com/resources/transactions/connect-to-a-bank-account)                          | [Setup and integrate](https://docs.tink.com/resources/transactions/setup-and-integrate-transactions#tink-link-for-ios)                    | [SDK reference](https://tink-ab.github.io/tink-link-ios/documentation/tinklink/) |
| **Report bundling**   | -                                                                                                                  | -                                                                                                                                         | [SDK reference](https://tink-ab.github.io/tink-link-ios/documentation/tinklink/) |

## Example app

- [TinkLinkSimpleSample](Samples/TinkLinkSimpleSample) shows how to build a complete flow for the Transaction product by using Tink Link in the easiest and fastest manner.

## SDK reference

For the full API reference, please see the [Tink Link iOS SDK Reference](https://tink-ab.github.io/tink-link-ios/documentation/tinklink/).