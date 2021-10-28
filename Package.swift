// swift-tools-version:5.3
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Live",
    platforms: [.iOS(.v14)],
    products: [
        .library(name: "Live", targets: ["Live"]),
        .library(name: "LivePlayer", targets: ["LivePlayer"])
    ],
    dependencies: [
        .package(url: "https://github.com/freshOS/Networking", .exact("0.3.0")),
        .package(url: "https://github.com/kean/FetchImage", .exact("0.2.1"))
    ],
    targets: [
        .target( name: "Live", dependencies: [ "Networking" ]),
        .target( name: "LivePlayer", dependencies: [ "Live", "FetchImage"]),
        .testTarget(name: "LiveTests", dependencies: ["Live"])
    ]
)
