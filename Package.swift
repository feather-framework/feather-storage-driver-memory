// swift-tools-version:5.9
import PackageDescription

let package = Package(
    name: "feather-storage-driver-memory",
    platforms: [
        .macOS(.v13),
        .iOS(.v16),
        .tvOS(.v16),
        .watchOS(.v9),
        .visionOS(.v1),
    ],
    products: [
        .library(name: "FeatherStorageDriverMemory", targets: ["FeatherStorageDriverMemory"]),
    ],
    dependencies: [
//        .package(url: "https://github.com/feather-framework/feather-storage.git", .upToNextMinor(from: "0.4.0")),
        .package(path: "../feather-storage")
    ],
    targets: [
        .target(
            name: "FeatherStorageDriverMemory",
            dependencies: [
                .product(name: "FeatherStorage", package: "feather-storage"),
            ]
        ),
        .testTarget(
            name: "FeatherStorageDriverMemoryTests",
            dependencies: [
                .product(name: "FeatherStorage", package: "feather-storage"),
                .product(name: "XCTFeatherStorage", package: "feather-storage"),
                .target(name: "FeatherStorageDriverMemory"),
            ]
        ),
    ]
)
