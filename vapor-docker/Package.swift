// swift-tools-version:6.0
import PackageDescription

var swiftSettings: [SwiftSetting] {
    [
        .enableUpcomingFeature("ExistentialAny"),
    ]
}


let package = Package(
    name: "vapor-docker",
    platforms: [
       .macOS(.v13)
    ],
    dependencies: [
        .package(url: "https://github.com/vapor/vapor", from: "4.110.1"),
        .package(url: "https://github.com/vapor/fluent", from: "4.9.0"),
        .package(url: "https://github.com/vapor/fluent-postgres-driver", from: "2.8.0"),
        .package(url: "https://github.com/apple/swift-nio", from: "2.65.0"),
    ],
    targets: [
        .executableTarget(
            name: "Server",
            dependencies: [
                .product(name: "Fluent", package: "fluent"),
                .product(name: "FluentPostgresDriver", package: "fluent-postgres-driver"),
                .product(name: "Vapor", package: "vapor"),
                .product(name: "NIOCore", package: "swift-nio"),
                .product(name: "NIOPosix", package: "swift-nio"),
            ],
            swiftSettings: swiftSettings
        ),
        .testTarget(
            name: "ServerTests",
            dependencies: [
                .product(name: "VaporTesting", package: "vapor"),
                .target(name: "Server"),
            ],
            swiftSettings: swiftSettings
        )
    ]
)

