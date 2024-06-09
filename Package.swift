// swift-tools-version: 5.10
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription
import CompilerPluginSupport

let package = Package(
    name: "ReduceDispatcher",
    platforms: [.macOS(.v13), .iOS(.v16), .tvOS(.v13), .watchOS(.v6), .macCatalyst(.v13)],
    products: [
        .library(
            name: "ReduceDispatcher",
            targets: ["ReduceDispatcher"]
        ),
        .executable(
            name: "ReduceDispatcherClient",
            targets: ["ReduceDispatcherClient"]
        ),
    ],
    dependencies: [
        .package(url: "https://github.com/apple/swift-syntax.git", from: "509.0.0"),
        .package(url: "https://github.com/pointfreeco/swift-composable-architecture.git", from: "1.10.2"),
        .package(url: "https://github.com/pointfreeco/swift-macro-testing", from: "0.4.0")
    ],
    targets: [
        .macro(
            name: "ReduceDispatcherImplementation",
            dependencies: [
                .product(name: "SwiftSyntaxMacros", package: "swift-syntax"),
                .product(name: "SwiftCompilerPlugin", package: "swift-syntax")
            ],
            path: "Sources/Implementation"
        ),
        .target(
            name: "ReduceDispatcher",
            dependencies: [
                "ReduceDispatcherImplementation",
                .product(name: "ComposableArchitecture", package: "swift-composable-architecture")
            ]
        ),
        .executableTarget(
            name: "ReduceDispatcherClient",
            dependencies: [
                "ReduceDispatcher"
            ],
            path: "Sources/Client"
        ),
        .testTarget(
            name: "ReduceDispatcherTests",
            dependencies: [
                "ReduceDispatcherImplementation",
                .product(name: "SwiftSyntaxMacrosTestSupport", package: "swift-syntax"),
                .product(name: "MacroTesting", package: "swift-macro-testing")
            ]
        ),
    ]
)
