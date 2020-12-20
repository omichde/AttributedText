// swift-tools-version:5.3
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
	name: "AttributedText",
	platforms: [
		.iOS(.v13)
	],
	products: [
		.library(
			name: "AttributedText",
			targets: ["AttributedText"]),
	],
	dependencies: [],
	targets: [
		.target(
			name: "AttributedText",
			dependencies: []),
		.testTarget(
			name: "AttributedTextTests",
			dependencies: ["AttributedText"]),
	]
)
