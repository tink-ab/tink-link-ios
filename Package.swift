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
        .package(name: "TinkCore", url: "https://github.com/tink-ab/tink-core-ios-private", .branch("1.0")),
        .package(url: "https://github.com/iwasrobbed/Down", .upToNextMajor(from: "0.9.3")),
        .package(url: "https://github.com/onevcat/Kingfisher", .upToNextMajor(from: "5.14.1"))
    ],
    targets: [
        .target(
            name: "TinkLink",
            dependencies: ["TinkCore"],
            exclude: ["Info.plist"]
        ),
        .testTarget(
            name: "TinkLinkTests",
            dependencies: ["TinkLink"]
        ),
        .target(
            name: "TinkLinkUI",
            dependencies: ["TinkCore", "TinkLink", "Down", "Kingfisher"],
            exclude: ["Generic/Extensions/Bundle+Module.swift"],
            resources: [.process("Assets.xcassets"), .process("Translations.bundle")]
        ),
        .testTarget(
            name: "TinkLinkUITests",
            dependencies: ["TinkLinkUI"]
        ),
    ]
)
