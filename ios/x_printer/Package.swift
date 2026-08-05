// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "x_printer",
    platforms: [
        .iOS("12.0")
    ],
    products: [
        .library(name: "x-printer", targets: ["x_printer"])
    ],
    dependencies: [],
    targets: [
        .binaryTarget(
            name: "PrinterSDK",
            path: "PrinterSDK.xcframework"
        ),
        .target(
            name: "x_printer",
            dependencies: ["PrinterSDK"]
        )
    ]
)
