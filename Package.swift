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
        .package(url: "https://github.com/tink-ab/tink-core-ios", .exact("0.1.5")),
        .package(url: "https://github.com/iwasrobbed/Down", .upToNextMajor(from: "0.9.3")),
        .package(url: "https://github.com/onevcat/Kingfisher", .upToNextMajor(from: "5.14.1"))
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
        .target(
            name: "TinkLinkUI",
            dependencies: ["TinkCore", "TinkLink", "Down", "Kingfisher"],
            exclude: ["Generic/Extensions/Bundle+Module.swift"],
            resources: [.copy("Assets.bundle"), .process("Translations.bundle")]
        ),
        .testTarget(
            name: "TinkLinkUITests",
            dependencies: ["TinkLinkUI"]
        ),
    ]
)
