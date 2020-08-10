// swift-tools-version:4.0
// The swift-tools-version declares the minimum version of Swift required to build this package.


import PackageDescription

let package = Package(
    name: "XServiceLocator",
    products: [
        .library(
            name: "XServiceLocator",
            targets: ["XServiceLocator"]),
    ],
    targets: [
        .target(
            name: "XServiceLocator",
            dependencies: []),
        .testTarget(
            name: "XServiceLocatorTests",
            dependencies: ["XServiceLocator"]),
    ]
)
