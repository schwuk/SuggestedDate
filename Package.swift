// swift-tools-version: 6.2
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "SuggestedDate",
    platforms: [
        .macOS(.v26), .iOS(.v26), .tvOS(.v26), .watchOS(.v26), .visionOS(.v26),
    ],
    products: [
        // Products define the executables and libraries a package produces, making them visible to other packages.
        .library(
            name: "SuggestedDate",
            targets: ["SuggestedDate"]
        ),
        .library(
            name: "SuggestedDateUI",
            targets: ["SuggestedDateUI"]
        ),
    ],
    dependencies: [
        .package(
            url: "https://github.com/swiftlang/swift-docc-plugin",
            from: "1.5.0"
        )
    ],
    targets: [
        // Targets are the basic building blocks of a package, defining a module or a test suite.
        // Targets can depend on other targets in this package and products from dependencies.
        .target(
            name: "SuggestedDate"
        ),
        .target(
            name: "SuggestedDateUI",
            dependencies: ["SuggestedDate"]
        ),
        .testTarget(
            name: "SuggestedDateTests",
            dependencies: ["SuggestedDate"]
        ),
        .testTarget(
            name: "SuggestedDateUITests",
            dependencies: ["SuggestedDateUI"]
        ),
    ]
)
