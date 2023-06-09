// swift-tools-version: 5.8
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "FZSwiftUtils",
    platforms: [.macOS("10.15"), .iOS(.v14), .macCatalyst(.v14), .tvOS(.v14), .watchOS(.v7)],
    products: [
        .library(
            name: "FZSwiftUtils",
            targets: ["FZSwiftUtils"]
        ),
    ],
    dependencies: [
    ],
    targets: [
        .target(
            name: "FZSwiftUtils",
            dependencies: []
        ),
        .testTarget(
            name: "FZSwiftUtilsTests",
            dependencies: ["FZSwiftUtils"]
        ),
    ]
)
