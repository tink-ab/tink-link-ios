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
        ),
        .library(
            name: "TinkLinkUI",
            targets: ["TinkLinkUI"]
        ),
    ],
    dependencies: [
        .package(url: "https://github.com/apple/swift-protobuf.git", .upToNextMajor(from: "1.7.0")),
        .package(url: "https://github.com/grpc/grpc-swift.git", .exact("1.0.0-alpha.9")),
        .package(url: "https://github.com/iwasrobbed/Down", .upToNextMajor(from: "0.8.1")),
        .package(url: "https://github.com/onevcat/Kingfisher", .upToNextMajor(from: "5.13.0"))
    ],
    targets: [
        .target(
            name: "TinkLink",
            dependencies: ["SwiftProtobuf", "GRPC"],
            exclude: ["TinkLinkUI"]
        ),
        .target(
            name: "TinkLinkUI",
            dependencies: ["TinkLink", "Down", "Kingfisher"],
            exclude: ["TinkLink"]
        ),
        .testTarget(
            name: "TinkLinkTests",
            dependencies: ["TinkLink"]
        ),
    ]
)
