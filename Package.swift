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
    targets: [
        .target(
            name: "TinkLink"
        ),
        .testTarget(
            name: "TinkLinkTests",
            dependencies: ["TinkLink"]
        ),
    ]
)
