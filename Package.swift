// swift-tools-version: 5.5
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "FZSwiftUtils",
    platforms: [.macOS(.v10_15), .iOS(.v14), .macCatalyst(.v14), .tvOS(.v14), .watchOS(.v6)],
    products: [
        .library(
            name: "FZSwiftUtils",
            targets: ["FZSwiftUtils"]
        ),
    ],
    dependencies: [
    ],
    targets: [
        .target(name: "_SuperBuilder", path: "Sources/FZSwiftUtils+ObjC/SuperBuilder"),
        .target(name: "_ExceptionCatcher", path: "Sources/FZSwiftUtils+ObjC/ExceptionCatcher", publicHeadersPath: "", cSettings: [.headerSearchPath(".")]),
        .target(
            name: "FZSwiftUtils",
            dependencies: ["_SuperBuilder", "_ExceptionCatcher"]
        ),
    ]
)
