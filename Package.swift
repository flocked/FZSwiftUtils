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
        .target(
            name: "_Libffi",
            path: "Sources/FZSwiftUtils+ObjC/Libffi",
            sources: ["src"],
            publicHeadersPath: "include",
            cSettings: [
                .define("USE_DL_PREFIX"),
                .unsafeFlags(["-Wno-deprecated-declarations", "-Wno-shorten-64-to-32"]),]
        ),
        .target(
            name: "_OCSources",
            dependencies: ["_Libffi"],
            path: "Sources/FZSwiftUtils+ObjC/OCSources",
            publicHeadersPath: ""),
        .target(name: "_SuperBuilder", path: "Sources/FZSwiftUtils+ObjC/SuperBuilder"),
        .target(name: "_ExceptionCatcher", path: "Sources/FZSwiftUtils+ObjC/ExceptionCatcher", publicHeadersPath: "", cSettings: [.headerSearchPath(".")]),
        .target(
            name: "FZSwiftUtils",
            dependencies: ["_SuperBuilder",
                           "_ExceptionCatcher",
                           .target(name: "_Libffi", condition: .when(platforms: [.iOS, .macCatalyst, .macOS])),
                           .target(name: "_OCSources", condition: .when(platforms: [.iOS, .macCatalyst, .macOS])),
                          ]
        ),
    ]
)
