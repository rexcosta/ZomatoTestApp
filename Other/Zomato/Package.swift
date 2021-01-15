// swift-tools-version:5.3
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Zomato",
    platforms: [
        .iOS(.v10),
        .macOS(.v11)
    ],
    products: [
        .library(
            name: "Zomato",
            targets: ["Zomato"]
        )
    ],
    dependencies: [
        .package(path: "../ZomatoFoundation")
    ],
    targets: [
        .target(
            name: "Zomato",
            dependencies: ["ZomatoFoundation"]
        ),
        .testTarget(
            name: "ZomatoTests",
            dependencies: ["Zomato"]
        )
    ]
)
