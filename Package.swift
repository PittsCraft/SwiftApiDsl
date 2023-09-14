// swift-tools-version: 5.8

import PackageDescription

let lint = true

var extraDependencies: [Package.Dependency] = []
var extraPlugins: [Target.PluginUsage] = []
if lint {
    extraDependencies = [.package(url: "https://github.com/realm/SwiftLint", from: "0.52.4")]
    extraPlugins = [.plugin(name: "SwiftLintPlugin", package: "SwiftLint")]
}

let package = Package(
    name: "SwiftApiDsl",
    platforms: [.iOS(.v13), .macOS(.v12)],
    products: [
        .library(
            name: "SwiftApiDsl",
            targets: ["SwiftApiDsl"])
    ],
    dependencies: [] + extraDependencies,
    targets: [
        .target(
            name: "SwiftApiDsl",
            dependencies: [],
            plugins: [] + extraPlugins),
        .testTarget(
            name: "SwiftApiDslTests",
            dependencies: ["SwiftApiDsl"],
            plugins: [] + extraPlugins)
    ]
)
