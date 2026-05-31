// swift-tools-version: 6.2
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "SimulatorHelper",
    platforms: [
        .macOS(.v15),
    ],
    products: [
        .executable(
            name: "SimulatorHelper",
            targets: ["SimulatorHelper"]
        ),
    ],
    targets: [
        .executableTarget(
            name: "SimulatorHelper"
        ),
        .testTarget(
            name: "SimulatorHelperTests",
            dependencies: ["SimulatorHelper"]
        ),
    ]
)
