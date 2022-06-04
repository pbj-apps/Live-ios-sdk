// swift-tools-version:5.3
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
		name: "Live",
		platforms: [.iOS(.v14)],
		products: [
				.library(name: "Live", targets: ["Live"]),
				.library(name: "LiveUI", targets: ["LiveUI"])
		],
		dependencies: [
				.package(url: "https://github.com/freshOS/Networking", .exact("1.2.1")),
				.package(url: "https://github.com/onevcat/Kingfisher", .exact("7.1.1"))
		],
		targets: [
				.target( name: "Live", dependencies: [ "Networking" ]),
				.target( name: "LiveUI", dependencies: [ "Live", "Kingfisher"]),
				.testTarget(name: "LiveTests", dependencies: ["Live"])
		]
)
