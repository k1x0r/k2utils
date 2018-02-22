// swift-tools-version:4.0

import PackageDescription

let package = Package(
    name: "k2Utils",
    products: [
        .library(
            name: "k2Utils",
            targets: ["k2Utils"]),
    ],
    dependencies: [
        // .package(url: /* package url */, from: "1.0.0"),
    ],
    targets: [
        .target(
            name: "k2Utils",
            dependencies: []),
        .testTarget(
            name: "DispatchChainTests",
            dependencies: ["k2Utils"]),
        .testTarget(
            name: "StringUtilsTests",
            dependencies: ["k2Utils"]),

    ]
)
