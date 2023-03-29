![Platforms](https://img.shields.io/badge/Platforms-iOS_13_14_15_16-brightgreen)
![Swift](https://img.shields.io/badge/Swift-5.7-blue)
![Xcode](https://img.shields.io/badge/Xcode-13_14-yellowgreen)
![CocoaPods](https://img.shields.io/cocoapods/v/TinkLink.svg)
![SPM](https://img.shields.io/badge/SPM-compatible-orange)

# Tink Link iOS

![Tink Link iOS](https://user-images.githubusercontent.com/3734694/228249248-b40cb9dd-eab1-41b6-af65-20d90040caca.png)

## Prerequisites

1. Go to [Set up your Tink Console account](https://docs.tink.com/resources/getting-started/set-up-your-account) and follow the steps to create a Console account and an app. Make a note of your `client_id`.
2. In Console, go to **App settings** > API client. In the Redirect URIs section, select **Add new redirect URI**. Add a redirect URI to your app. Your redirect URI needs a scheme and host, for example: `awesomeApp://callback`.

## Requirements

1. iOS 13.0
2. Xcode 13.0

## Installation

#### Using Swift Package Manager

Add a [package dependency](https://help.apple.com/xcode/mac/current/#/devb83d64851) in Xcode to your app target.

1. In Xcode, select _File > Add Packages..._
2. Enter `https://github.com/tink-ab/tink-link-ios` as the repository URL
3. Add the `TinkLink` product to the [target of your app](https://developer.apple.com/documentation/xcode/adding-package-dependencies-to-your-app)

#### Using CocoaPods

Add `TinkLink` to your `Podfile`.

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

## Example app

- [TinkLinkSimpleSample](Samples/TinkLinkSimpleSample) shows how to build a complete flow for the Transaction product by using Tink Link in the easiest and fastest manner.

## SDK reference

For the full API reference, please see the [Tink Link iOS SDK Reference](https://tink-ab.github.io/tink-link-ios/documentation/tinklink/).