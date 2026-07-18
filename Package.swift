// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "FZSwiftUtils",
    platforms: [.macOS(.v12), .iOS(.v15), .macCatalyst(.v15), .tvOS(.v15), .watchOS(.v8), .visionOS(.v1)],
    products: [
        .library(
            name: "FZSwiftUtils",
            targets: ["FZSwiftUtils"]
        ),
    ],
    dependencies: [],
    targets: [
        .target(
            name: "FZSwiftUtils",
            dependencies: [
                "_FZSwiftUtilsObjC",
                .target(
                    name: "_Libffi",
                    condition: .when(platforms: [.macOS, .iOS, .macCatalyst, .tvOS, .watchOS, .visionOS])
                ),
            ]
        ),
        .target(name: "_Libffi",
                path: "Sources/Libffi",
                exclude: ["vendor"],
                publicHeadersPath: "include",
            cSettings: [
                .define("DARWIN"),
                .headerSearchPath("include"),
                .define("USE_DL_PREFIX"),
                .unsafeFlags(["-Wno-deprecated-declarations", "-Wno-shorten-64-to-32"])
            ]
               ),
        .target(
            name: "_FZSwiftUtilsObjC",
            dependencies: [
                .target(
                    name: "_Libffi",
                    condition: .when(platforms: [.macOS, .iOS, .macCatalyst, .tvOS, .watchOS, .visionOS])
                ),
            ],
            path: "Sources/FZSwiftUtils+ObjC",
            publicHeadersPath: "include",
            cSettings: [
                .headerSearchPath("include"),
            ]
        ),
    ]
)
