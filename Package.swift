// swift-tools-version: 5.10

import PackageDescription

let package = Package(
    name: "TinkLink",
    platforms: [
        .iOS(.v14)
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
