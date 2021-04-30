![Platform](https://img.shields.io/badge/platform-iOS-orange.svg)
![Languages](https://img.shields.io/badge/languages-swift-orange.svg)

# TinkLink Sample

This directory contains sample code that demonstrates the usage of `TinkLinkUI` target in `TinkLink` iOS SDK. 

![Tink Link](https://images.ctfassets.net/tmqu5vj33f7w/4YdZUwzfmUjvNKO0tHvKVj/ec14ed052771e3ef10156c29ccf004f0/overview.png)

## Prerequisites
1. Follow the [getting started guide](https://docs.tink.com/resources/getting-started/set-up-your-account) to retrieve your `client_id`.
2. Add a `link-demo://tink`) to the [list of redirect URIs under your app's settings](https://console.tink.com/overview).

## Configuration
Before running the sample project open `TinkLinkExample` and configure the following:

1. Configure your client ID. Update `TINK_LINK_EXAMPLE_CLIENT_ID` environment variables in `TinkLinkExample` scheme argument or `YOUR_CLIENT_ID` in `ViewController.swift` with a valid access token.

## Running the sample app
1. Open `TinkLinkExample.xcodeproj` in Xcode.
2. Press the run button. If all went well, this should launch a simulator with the sample app running.

## Enterprise account
`TinkLinkUI` also support using enterprise account with permanent user, to use that in `TinkLinkExample` you need to:
1. Set a valid user access token. If you don't have one already, please follow our [guide](https://docs.tink.com/resources/getting-started/get-access-token) on how to generate a new API token. Note that these can expire, so make sure that you're using one that's currently active.
2. Update `TINK_LINK_EXAMPLE_ACCESS_TOKEN` environment variables in `TinkLinkExample` scheme argument with a valid access token.
