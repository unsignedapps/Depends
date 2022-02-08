// swift-tools-version:5.5
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Depends",
    platforms: [
        .iOS(.v13),
        .macOS(.v10_15),
        .tvOS(.v13),
        .watchOS(.v6)
    ],

    products: [
        .library(name: "Depends-auto", targets: [ "Depends" ]),
        .library(name: "TestDepends-auto", targets: [ "Depends", "TestDepends" ]),

        .library(name: "Depends", type: .dynamic, targets: [ "Depends" ]),
    ],


    // MARK: - Source Dependencies

    dependencies: [
    ],


    // MARK: - Targets

    targets: [
        .target(name: "Depends", dependencies: []),
        .testTarget(name: "DependsTests", dependencies: [ "Depends", "TestDepends" ]),

        .target(name: "TestDepends", dependencies: [ "Depends" ]),
    ]
)
