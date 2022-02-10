// swift-tools-version:5.3

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
        ),
        .library(
            name: "TinkLinkUI",
            targets: ["TinkLinkUI"]
        )
    ],
    dependencies: [
        .package(name: "TinkCore", url: "https://github.com/tink-ab/tink-core-ios", .upToNextMajor(from: "1.5.5")),
        .package(url: "https://github.com/johnxnguyen/Down", .upToNextMajor(from: "0.11.0"))
    ],
    targets: [
        .target(
            name: "TinkLink",
            dependencies: [.product(name: "TinkCore", package: "TinkCore")],
            exclude: ["Info.plist"]
        ),
        .testTarget(
            name: "TinkLinkTests",
            dependencies: ["TinkLink"],
            exclude: ["Info.plist"]
        ),
        .target(
            name: "TinkLinkUI",
            dependencies: [.product(name: "TinkCore", package: "TinkCore"), "TinkLink", "Down"],
            exclude: ["Generic/Extensions/Bundle+Module.swift", "Info.plist"],
            resources: [.process("Assets.xcassets"), .process("Translations.bundle")]
        ),
        .testTarget(
            name: "TinkLinkUITests",
            dependencies: ["TinkLinkUI"],
            exclude: ["Info.plist"]
        ),
    ]
)
