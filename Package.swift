// swift-tools-version:5.3
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
	name: "LiveCore",
	platforms: [.iOS(.v13)],
	products: [.library(name: "LiveCore", targets: ["LiveCore"])],
	dependencies: [
		.package(url: "https://github.com/freshOS/Networking", .exact("0.3.0")),
		.package(url: "https://github.com/kean/FetchImage", .exact("0.2.1")),
		.package(name: "Firebase", url: "https://github.com/firebase/firebase-ios-sdk", .branch("7.0-spm-beta")),
		.package(url: "https://github.com/alickbass/CodableFirebase", .exact("0.2.2"))
	],
	targets: [
		.target( name: "LiveCore", dependencies: [
			"Networking",
			"FetchImage",
			"CodableFirebase",
			.product(name: "FirebaseFirestore", package: "Firebase")
		]),
		.testTarget(name: "LiveCoreTests", dependencies: ["LiveCore"])
	]
)
