// swift-tools-version: 5.5
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "FZSwiftUtils",
    platforms: [.macOS("10.15"), .iOS(.v14), .macCatalyst(.v14), .tvOS(.v14), .watchOS(.v6)],
    products: [
        .library(
            name: "FZSwiftUtils",
            targets: ["FZSwiftUtils"]
        ),
    ],
    dependencies: [
    ],
    targets: [
        .target(name: "SuperBuilder"),
        .target(
            name: "FZSwiftUtils",
            dependencies: ["SuperBuilder"]
        ),
    ]
)
