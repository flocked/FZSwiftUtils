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
        .package(url: "https://github.com/623637646/libffi.git", from: "3.4.7")
    ],
    targets: [
        .target(name: "_OCSources", dependencies: [.product(name: "libffi_apple", package: "libffi")], path: "Sources/FZSwiftUtils+ObjC/OCSources", publicHeadersPath: ""),
        .target(name: "_SuperBuilder", path: "Sources/FZSwiftUtils+ObjC/SuperBuilder"),
        .target(name: "_ExceptionCatcher", path: "Sources/FZSwiftUtils+ObjC/ExceptionCatcher", publicHeadersPath: "", cSettings: [.headerSearchPath(".")]),
        .target(name: "_NSObjectProxy", path: "Sources/FZSwiftUtils+ObjC/NSObjectProxy"),
        .target(name: "FZSwiftUtils",
            dependencies: ["_SuperBuilder", "_ExceptionCatcher", "_NSObjectProxy",
                           .product(name: "libffi_apple", package: "libffi", condition: .when(platforms: [.iOS, .macCatalyst, .macOS])),
                           .target(name: "_OCSources", condition: .when(platforms: [.iOS, .macCatalyst, .macOS])),
                          ]),
    ]
)
