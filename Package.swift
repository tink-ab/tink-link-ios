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
        .package(url: "https://github.com/tink-ab/tink-core-ios", .exact("0.1.6"))
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
