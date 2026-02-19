// swift-tools-version: 5.5
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "FZSwiftUtils",
    platforms: [.macOS(.v12), .iOS(.v15), .macCatalyst(.v15), .tvOS(.v15), .watchOS(.v8)],
    products: [
        .library(
            name: "FZSwiftUtils",
            targets: ["FZSwiftUtils"]
        ),
    ],
    dependencies: [],
    targets: [
        .target(name: "FZSwiftUtils", dependencies: ["_FZSwiftUtilsObjC", "_Libffi"]),
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
            dependencies: ["_Libffi"],
            path: "Sources/FZSwiftUtils+ObjC",
            publicHeadersPath: "include",
            cSettings: [
                .headerSearchPath("include"),
            ]
        ),
    ]
)
