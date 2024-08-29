![Platforms](https://img.shields.io/badge/Platforms-iOS_13_14_15_16_17-brightgreen)
![Swift](https://img.shields.io/badge/Swift-5.9-blue)
![Xcode](https://img.shields.io/badge/Xcode-15-yellowgreen)
![CocoaPods](https://img.shields.io/cocoapods/v/TinkLink.svg)
![SPM](https://img.shields.io/badge/SPM-compatible-orange)

# Tink Link iOS

![Tink Link iOS](https://github.com/tink-ab/tink-link-ios/assets/3734694/6d579562-14ec-4e89-a5d0-55b7ee0abb8a)


## Prerequisites

1. [Set up your Tink Console account](https://docs.tink.com/resources/console/set-up-your-tink-account) and retrieve the `client ID` for your app.
2. Add a universal link (or deep link) to your app in the list of redirect URIs under _App settings > API client_ (eg. `myapp://callback`).
3. Add a universal link (or deep link) scheme into supported URL Types of your app:
    * Open your iOS project (xcodeproj file).
    * Select your app in the list `Targets`.
    * Open `Info` section.
    * Navigate down and expand `URL Types` section.
    * Press plus (`+`) button.
    * Add your universal link (or deep link) scheme into `URL Schemes` field (eg. `myapp`).

## Requirements

1. iOS 13.0
2. Xcode 15.0
3. Swift 5.9

## Installation

#### Using Swift Package Manager

Add a [package dependency](https://help.apple.com/xcode/mac/current/#/devb83d64851) in Xcode to your app target.

1. In Xcode, select _File > Add Packages..._
2. Enter `https://github.com/tink-ab/tink-link-ios` as the repository URL.
3. Add the `TinkLink` product to the [target of your app](https://developer.apple.com/documentation/xcode/adding-package-dependencies-to-your-app).

#### Using CocoaPods

Add `TinkLink` to your `Podfile`:

```ruby
pod "TinkLink"
```

#### Using manual installation

1. Download and extract the `TinkLink.xcframework` from the [releases page on GitHub](https://github.com/tink-ab/tink-link-ios/releases).
2. Drag `TinkLink.xcframework` to the _Frameworks, Libraries, and Embedded Content_ section of the _General_ settings tab for your application target in your Xcode project. Make sure to select Copy items if needed.

## Launching the SDK

To launch the SDK in your iOS app, please see the product specific documentation.

|                       |                                                                                                                    |                                                                                                                                           |                                                                                                   |
| --------------------- | ------------------------------------------------------------------------------------------------------------------ | ----------------------------------------------------------------------------------------------------------------------------------------- | ------------------------------------------------------------------------------------------------- |
| **Account Check**     | [Getting started](https://docs.tink.com/resources/account-check/verify-your-first-account)                         | [Setup and integrate](https://docs.tink.com/resources/account-check/setup-and-integrate-account-check#tink-link-for-ios)                  | [SDK reference](https://tink-ab.github.io/tink-link-ios/documentation/tinklink/tink/accountcheck) |
| **Expense Check**     | [Getting started](https://docs.tink.com/resources/expense-check/fetch-your-first-expense-check-report)             | [Setup and integrate](https://docs.tink.com/resources/expense-check/setup-and-integrate-expense-check#tink-link-for-ios)                  | [SDK reference](https://tink-ab.github.io/tink-link-ios/documentation/tinklink/tink/expensecheck) |
| **Income Check**      | [Getting started](https://docs.tink.com/resources/income-check/fetch-your-first-income-check-report)               | [Setup and integrate](https://docs.tink.com/resources/income-check/setup-and-integrate-income-check#tink-link-for-ios)                    | [SDK reference](https://tink-ab.github.io/tink-link-ios/documentation/tinklink/tink/incomecheck)  |
| **One-time payments** | [Getting started](https://docs.tink.com/resources/payments/one-time-payments/initiate-your-first-one-time-payment) | [Setup and integrate](https://docs.tink.com/resources/payments/one-time-payments/setup-and-integrate-one-time-payments#tink-link-for-ios) | [SDK reference](https://tink-ab.github.io/tink-link-ios/documentation/tinklink/tink/payments)     |
| **Risk Insights**     | [Getting started](https://docs.tink.com/resources/risk-insights/fetch-your-first-risk-insights-report)             | [Setup and integrate](https://docs.tink.com/resources/risk-insights/setup-and-integrate-risk-insights#tink-link-for-ios)                  | [SDK reference](https://tink-ab.github.io/tink-link-ios/documentation/tinklink/tink/riskinsights) |
| **Transactions**      | [Getting started](https://docs.tink.com/resources/transactions/connect-to-a-bank-account)                          | [Setup and integrate](https://docs.tink.com/resources/transactions/setup-and-integrate-transactions#tink-link-for-ios)                    | [SDK reference](https://tink-ab.github.io/tink-link-ios/documentation/tinklink/tink/transactions) |
| **Report bundling**   | -                                                                                                                  | -                                                                                                                                         | [SDK reference](https://tink-ab.github.io/tink-link-ios/documentation/tinklink/tink/reports)      |
| **Account Aggregation** | [Getting started](https://docs.tink.com/resources/aggregation) | - | [SDK reference](https://tink-ab.github.io/tink-link-ios/documentation/tinklink/tink/accountaggregation) |

## Preselecting a provider

You can also optimize your integration in different ways, such as [preselecting a provider](https://docs.tink.com/resources/account-check/optimize-your-account-check-integration#preselecting-a-bank). To preselect a provider, simply specify your provider name as a value to the `inputProvider` argument for the API calls where it's available, like in this example:

```swift
let viewController = Tink.Transactions.connectAccountsForOneTimeAccess(
    configuration: config,
    market: market,
    inputProvider: "sbab-bankid",
    completion: handler
)
```

Parameter `inputProvider` gives the option to use the data to skip the provider-selection screen and preselect the user's provider (in this example, SBAB is preselected).

To get the list of all providers available for an authenticated user, please refer to [list-providers](https://docs.tink.com/api#connectivity/provider/list-provider-identifiers). To get the list of all providers on a specified market, please refer to [list-providers-for-a-market](https://docs.tink.com/api#connectivity/provider/list-providers-for-a-market).

## Example app

- [TinkLinkSimpleSample](Samples/TinkLinkSimpleSample) shows how to build a complete flow for the Transaction product by using Tink Link in the easiest and fastest manner.

## SDK reference

For the full API reference, please see the [Tink Link iOS SDK Reference](https://tink-ab.github.io/tink-link-ios/documentation/tinklink/).

## Support

For any questions and/or support, please contact us directly here: https://docs.tink.com/resources/support.
