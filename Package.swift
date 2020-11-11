// swift-tools-version:5.3
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
	name: "Live",
	platforms: [.iOS(.v13)],
	products: [.library(name: "Live", targets: ["Live"])],
	dependencies: [
		.package(url: "https://github.com/freshOS/Networking", .exact("0.3.0")),
		.package(url: "https://github.com/kean/FetchImage", .exact("0.2.1"))
	],
	targets: [
		.target( name: "Live", dependencies: [
			"Networking",
			"FetchImage"
		]),
		.testTarget(name: "LiveTests", dependencies: ["Live"])
	]
)
