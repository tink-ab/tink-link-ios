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
        .package(name: "TinkCore", url: "https://github.com/tink-ab/tink-core-ios", .upToNextMinor(from: "0.1.6")),
        .package(url: "https://github.com/iwasrobbed/Down", .upToNextMajor(from: "0.9.3")),
        .package(url: "https://github.com/onevcat/Kingfisher", .upToNextMajor(from: "5.14.1"))
    ],
    targets: [
        .target(
            name: "TinkLink",
            dependencies: [.product(name: "TinkCoreXCFramework", package: "TinkCore")],
            exclude: ["Info.plist"]
        ),
        .testTarget(
            name: "TinkLinkTests",
            dependencies: ["TinkLink"],
            exclude: ["Info.plist"]
        ),
        .target(
            name: "TinkLinkUI",
            dependencies: [.product(name: "TinkCoreXCFramework", package: "TinkCore"), "TinkLink", "Down", "Kingfisher"],
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
