// swift-tools-version:5.5
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "LineHolderView",
    platforms: [
        .iOS(.v9)
    ],
    products: [
        .library(
            name: "LineHolderView",
            targets: ["LineHolderView"]),
    ],
    targets: [
        .target(
            name: "LineHolderView",
            dependencies: []),
        .testTarget(
            name: "LineHolderViewTests",
            dependencies: ["LineHolderView"]),
    ]
)
