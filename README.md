# Feather Storage Driver Memory

A testing purpose only in-memory storage driver for the Feather CMS storage service.

## Getting started

⚠️ This repository is a work in progress, things can break until it reaches v1.0.0. 

Use at your own risk.

### Adding the dependency

To add a dependency on the package, declare it in your `Package.swift`:

```swift
.package(url: "https://github.com/feather-framework/feather-storage-driver-memory.git", .upToNextMinor(from: "0.1.0")),
```

and to your application target, add `FeatherStorage` to your dependencies:

```swift
.product(name: "FeatherStorageDriverMemory", package: "feather-storage-driver-memory")
```

Example `Package.swift` file with `FeatherStorage` as a dependency:

```swift
// swift-tools-version:5.9
import PackageDescription

let package = Package(
    name: "my-application",
    dependencies: [
        .package(url: "https://github.com/feather-framework/feather-storage-driver-memory.git", .upToNextMinor(from: "0.1.0")),
    ],
    targets: [
        .target(name: "MyApplication", dependencies: [
            .product(name: "FeatherStorageDriverMemory", package: "feather-storage-driver-memory")
        ]),
        .testTarget(name: "MyApplicationTests", dependencies: [
            .target(name: "MyApplication"),
        ]),
    ]
)
```

