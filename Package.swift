// swift-tools-version:5.0

import PackageDescription

let package = Package(
    name: "TinkLink",
    platforms: [
        .iOS(.v11),
        .macOS(.v10_13)
    ],
    products: [
        .library(
            name: "TinkLink",
            targets: ["TinkLink"]
        )
    ],
    dependencies: [
        .package(path: "../tink-core-ios")
    ],
    targets: [
        .target(
            name: "TinkLink",
            dependencies: ["TinkCore"]
        ),
        .testTarget(
            name: "TinkLinkTests",
            dependencies: ["TinkLink"]
        ),
    ]
)
