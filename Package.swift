// swift-tools-version:5.3
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
	name: "LiveCore",
	platforms: [.iOS(.v13)],
	products: [.library(name: "LiveCore", targets: ["LiveCore"])],
	dependencies: [
		.package(url: "https://github.com/freshOS/Networking", .exact("0.3.0")),
		.package(url: "https://github.com/kean/FetchImage", .exact("0.2.1"))
	],
	targets: [
		.target( name: "LiveCore", dependencies: [
			"Networking",
			"FetchImage"
		]),
		.testTarget(name: "LiveCoreTests", dependencies: ["LiveCore"])
	]
)
