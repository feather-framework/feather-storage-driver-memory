// swift-tools-version:5.9
import PackageDescription

let package = Package(
    name: "feather-storage-driver-memory",
    platforms: [
        .macOS(.v10_15)
    ],
    products: [
        .library(name: "FeatherStorageDriverMemory", targets: ["FeatherStorageDriverMemory"]),
    ],
    dependencies: [
        .package(url: "https://github.com/feather-framework/feather-storage.git", .upToNextMinor(from: "0.1.0")),
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
