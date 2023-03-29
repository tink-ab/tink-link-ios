// swift-tools-version: 5.7

import PackageDescription

let package = Package(
    name: "TinkLink",
    platforms: [
        .iOS(.v13)
    ],
    products: [
        .library(
            name: "TinkLink",
            targets: ["TinkLink"])
    ],
    targets: [
        .binaryTarget(
            name: "TinkLink",
            path: "TinkLink.xcframework")
    ]
)
