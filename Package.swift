// swift-tools-version: 5.8

import PackageDescription

let lint = false

var extraDependencies: [Package.Dependency] = []
var extraPlugins: [Target.PluginUsage] = []
if lint {
    extraDependencies = [.package(url: "https://github.com/realm/SwiftLint", exact: "0.52.4")]
    extraPlugins = [.plugin(name: "SwiftLintPlugin", package: "SwiftLint")]
}

let package = Package(
    name: "SwiftApiDsl",
    platforms: [.iOS(.v13), .macOS(.v10_15)],
    products: [
        .library(
            name: "SwiftApiDsl",
            targets: ["SwiftApiDsl"]),
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
            plugins: [] + extraPlugins),
    ]
)
