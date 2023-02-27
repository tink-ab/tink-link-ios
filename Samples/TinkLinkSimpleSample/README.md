![Platforms](https://img.shields.io/badge/Platforms-iOS_13_14_15_16-brightgreen)
![Swift](https://img.shields.io/badge/Swift-5.7-blue)
![Xcode](https://img.shields.io/badge/Xcode-13_14-yellowgreen)

# Simple Sample
An iOS app designed to demonstrate a simple use case of the `TinkLink` for iOS.

## Prerequisites

1. Follow the [getting started guide](https://docs.tink.com/resources/getting-started/set-up-your-account) to set up your Tink account and to retrieve your `clientID`.

2. Add `tinksdk://example` into the [list of redirect URIs under your app's settings in Console](https://console.tink.com/overview).

## How to run the sample app

1. Open `TinkLinkSimpleSample.xcodeproj`.

2. Replace `clientID` placeholder in the source code with a `clientID` you retrieved in the [Prerequisites](##Prerequisites) section.

3. Optionally: replace “SE” market with another one from [the list of available markets ](https://docs.tink.com/resources/tink-link-web/tink-link-web-api-reference-transactions#markets).

4. Make sure `TinkLinkSimpleSample` is selected as a target.

5. Select any `iOS iPhone Simulator` as deployment target device. In case of need to run the app on a real device please fulfill targets `Signing` settings according to your Apple Developer account’s preferences.

6. Run the sample app by hitting `Command+R` or by pressing the triangle (`Run`) button in the top-left corner of Xcode.

7. Inside the app press the `Start the flow` button.