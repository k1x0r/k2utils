// swift-tools-version:4.2

import PackageDescription

let package = Package(
    name: "k2Utils",
    products: [
        .library(
            name: "k2Utils",
            targets: ["k2Utils"]),
        .library(
            name: "KeychainWrapper",
            targets: ["KeychainWrapper"])
    ],
    dependencies: [
        // .package(url: /* package url */, from: "1.0.0"),
    ],
    targets: [
        .target(
            name: "k2Utils",
            dependencies: []
        ),
        .target(
            name: "KeychainWrapper",
            dependencies: ["k2Utils"]
        ),
        .testTarget(
            name: "DispatchChainTests",
            dependencies: ["k2Utils"]),
        .testTarget(
            name: "StringUtilsTests",
            dependencies: ["k2Utils"]),

    ]
)
