// swift-tools-version:5.3
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "ZomatoUIKit",
    platforms: [
        .iOS(.v12),
        .macOS(.v11)
    ],
    products: [
        .library(
            name: "ZomatoUIKit",
            targets: ["ZomatoUIKit"]
        )
    ],
    dependencies: [
        .package(path: "../ZomatoFoundation")
    ],
    targets: [
        .target(
            name: "ZomatoUIKit",
            dependencies: ["ZomatoFoundation"]
        ),
        .testTarget(
            name: "ZomatoUIKitTests",
            dependencies: ["ZomatoUIKit"]
        )
    ]
)
