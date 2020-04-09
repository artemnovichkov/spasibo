// swift-tools-version:5.1
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Spasibo",
    products: [
        .executable(name: "Spasibo", targets: ["Spasibo"])
    ],
    dependencies: [
        .package(url: "https://github.com/Carthage/Carthage.git", .upToNextMajor(from: "0.0.0")),
        .package(url: "https://github.com/jpsim/Yams.git", .upToNextMajor(from: "2.0.0")),
        .package(url: "https://github.com/apple/swift-argument-parser.git", .upToNextMinor(from: "0.0.0")),
    ],
    targets: [
        .target(name: "Spasibo", dependencies: ["CarthageKit", "Yams", "ArgumentParser"])
    ]
)
